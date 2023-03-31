#!/usr/bin/env python
""" Helper script to update SNAP update center with new NBMs
This code is released under GPL-3 or any later version.
"""


import os
import shutil
import argparse
import datetime
import logging
import zipfile
from lxml import etree
import StringIO
import gzip
import re


__author__ = "Julien Malik, Marco Peters"
__copyright__ = "Copyright 2015, CS-SI"
__credits__ = ["Julien Malik", "Marco Peters"]
__license__ = "GPL"
__version__ = "1.0"
__maintainer__ = "Marco Peters"
__email__ = "marco.peters@brockmann-consult.de"
__status__ = "Production"



def is_nbm(path):
    # TODO : add more sanity checks to avoid corrupted nbms
    return os.path.isfile(path) and os.path.splitext(path)[1] == ".nbm"


def check_nbm_dir(nbmdir):
    if not os.path.isdir(nbmdir):
        raise argparse.ArgumentTypeError("%s is not a directory" % nbmdir)
    # nbms = [f for f in os.listdir(nbmdir) if is_nbm(os.path.join(nbmdir, f))]
    # if not nbms:
    #     raise argparse.ArgumentTypeError("%s does not contain any nbm file" % nbmdir)
    return nbmdir

def check_release(release):
    if not re.match('[0-9]+\.x', release):
        raise argparse.ArgumentTypeError("Release version does not match pattern ([0-9]+\.[0-9]+): %s" % release)
    return release

def setup_logging():
    logging.basicConfig(format='%(asctime)s - %(levelname)s: %(message)s', level=logging.DEBUG)

def get_module_info(nbm):
    f = zipfile.ZipFile(nbm)
    with f.open('Info/info.xml') as info:
        root = etree.parse(info).getroot()

        children = list(root)
        license = None
        for child in children:
            if child.tag == 'license':
                license = child
        if license is not None:
            del root[root.index(license)]

        root.set('downloadsize', str(os.path.getsize(nbm)))
    return (root, license)


def get_dtd():
    # content of http://www.netbeans.org/dtds/autoupdate-catalog-2_5.dtd
    dtdstr = """
<!-- -//NetBeans//DTD Autoupdate Catalog 2.5//EN -->
<!-- XML representation of Autoupdate Modules/Updates Catalog -->
<!ELEMENT module_updates ((notification?, (module_group|module)*, license*)|error)>
<!ATTLIST module_updates timestamp CDATA #REQUIRED>
<!ELEMENT module_group ((module_group|module)*)>
<!ATTLIST module_group name CDATA #REQUIRED>
<!ELEMENT notification (#PCDATA)>
<!ATTLIST notification url CDATA #IMPLIED>
<!ELEMENT module (description?, module_notification?, external_package*, (manifest | l10n) )>
<!ATTLIST module codenamebase CDATA #REQUIRED
                 homepage     CDATA #IMPLIED
                 distribution CDATA #REQUIRED
                 license      CDATA #IMPLIED
                 downloadsize CDATA #REQUIRED
                 needsrestart (true|false) #IMPLIED
                 moduleauthor CDATA #IMPLIED
                 releasedate  CDATA #IMPLIED
                 global       (true|false) #IMPLIED
                 targetcluster CDATA #IMPLIED
                 eager (true|false) #IMPLIED
                 autoload (true|false) #IMPLIED>
<!ELEMENT description (#PCDATA)>
<!ELEMENT module_notification (#PCDATA)>
<!ELEMENT external_package EMPTY>
<!ATTLIST external_package
                 name CDATA #REQUIRED
                 target_name  CDATA #REQUIRED
                 start_url    CDATA #REQUIRED
                 description  CDATA #IMPLIED>
<!ELEMENT manifest EMPTY>
<!ATTLIST manifest OpenIDE-Module CDATA #REQUIRED
                   OpenIDE-Module-Name CDATA #REQUIRED
                   OpenIDE-Module-Specification-Version CDATA #REQUIRED
                   OpenIDE-Module-Implementation-Version CDATA #IMPLIED
                   OpenIDE-Module-Module-Dependencies CDATA #IMPLIED
                   OpenIDE-Module-Package-Dependencies CDATA #IMPLIED
                   OpenIDE-Module-Java-Dependencies CDATA #IMPLIED
                   OpenIDE-Module-IDE-Dependencies CDATA #IMPLIED
                   OpenIDE-Module-Short-Description CDATA #IMPLIED
                   OpenIDE-Module-Long-Description CDATA #IMPLIED
                   OpenIDE-Module-Display-Category CDATA #IMPLIED
                   OpenIDE-Module-Provides CDATA #IMPLIED
                   OpenIDE-Module-Requires CDATA #IMPLIED
                   OpenIDE-Module-Recommends CDATA #IMPLIED
                   OpenIDE-Module-Needs CDATA #IMPLIED
                   AutoUpdate-Show-In-Client (true|false) #IMPLIED
                   AutoUpdate-Essential-Module (true|false) #IMPLIED>
<!ELEMENT l10n EMPTY>
<!ATTLIST l10n   langcode             CDATA #IMPLIED
                 brandingcode         CDATA #IMPLIED
                 module_spec_version  CDATA #IMPLIED
                 module_major_version CDATA #IMPLIED
                 OpenIDE-Module-Name  CDATA #IMPLIED
                 OpenIDE-Module-Long-Description CDATA #IMPLIED>
<!ELEMENT license (#PCDATA)>
<!ATTLIST license name CDATA #REQUIRED>
"""
    dtdio = StringIO.StringIO(dtdstr)
    dtd = etree.DTD(dtdio)
    dtdio.close()
    return dtd


def generate_updatexml(repo):
    nbms = [f for f in os.listdir(repo) if is_nbm(os.path.join(repo, f))]

    licenses = set()
    module_updates = etree.Element('module_updates', timestamp='{0:%S/%M/%H/%d/%m/%Y}'.format(datetime.datetime.now()))

    for nbm in nbms:
        nbm_path = os.path.join(repo, nbm)
        (root, license) = get_module_info(nbm_path)
        module_updates.append(root)
        if license is not None:
            # add this license, if not already done
            if {lic for lic in licenses if lic.get('name') == license.get('name')} == set():
                licenses.add(license)

    if len(licenses) > 1:
        logging.warn('Modules have %d different licenses' % len(licenses))
    for license in licenses:
        module_updates.append(license)

    with open(os.path.join(repo, 'updates.xml'), 'w') as updates_file:
        updates_file.write(etree.tostring(module_updates, pretty_print=True, encoding="UTF-8", xml_declaration=True,
                                          doctype='<!DOCTYPE module_updates PUBLIC "-//NetBeans//DTD Autoupdate Catalog 2.5//EN" "http://www.netbeans.org/dtds/autoupdate-catalog-2_5.dtd">'))

    # validate DTD
    dtd = get_dtd()
    with open(os.path.join(repo, 'updates.xml'), 'r') as updates_file:
        if not dtd.validate(etree.parse(updates_file)):
            message = 'Generated updates.xml does not validate DTD !'
            logging.error(message)
            raise RuntimeError(message)
        else:
            logging.info('Generated updates.xml validates DTD successfully')

    # gz
    with open(os.path.join(repo, 'updates.xml'), 'rb') as f_in, \
            gzip.open(os.path.join(repo, 'updates.xml.gz'), 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)


def main():
    parser = argparse.ArgumentParser(prog='deploy_nbm.py', description='Generate updates.xml from nbm files')
    parser.add_argument('nbmdir', nargs='?', help='The directory containing the new nbm files to deploy',
                        type=check_nbm_dir)
    args = parser.parse_args()
    setup_logging()
    generate_updatexml(args.nbmdir)



if __name__ == "__main__":
    main()

