#!/usr/bin/python3
# This script will to help to manage rhpam components modules version, it will update all needed files
# Example of usage:
#   # move the current version to the next one or rcX
#   python3 scripts/update-version.py -v 8.0.1 --confirm
#
#   # to only see the proposed changes (dry run):
#   python3 scripts/update-version.py -v 8.0.1
#
# Version pattern is: X.YY.Z
# Dependencies:
#  ruamel.yaml

import argparse
import glob
import os
import re
import sys

from ruamel.yaml import YAML

# All rhpam modules that will be updated.
IMAGES_DIR = {"businesscentral", "businesscentral-monitoring",
              "controller", "dashbuilder", "kieserver",
              "process-migration", "smartrouter"}

# e.g. 8.0.1
VERSION_REGEX = re.compile(r'\b8[.]\d[.]\d\b')
# e.g. 8
SHORTENED_VERSION_REGEX = re.compile(r'\b8')
# 0 is just a place holder, yaml suffix will be appended when needed
IMAGESTREAM = "ibm-bamoe0-image-streams"
RHPAM_PREFIX_REGEX = re.compile(r'ibm-bamoe0')

# TODO add option to update the version in the quickstarts as well update the tag for each README.


def yaml_loader():
    """
    default yaml Loader
    :return: yaml object
    """
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 1024
    yaml.indent(mapping=2, sequence=4, offset=2)
    return yaml


def get_shortened_version(version):
    return str(version).split(".")[0]


def get_current_imagestream_filename():
    for name in glob.glob('ibm-bamoe8-image-streams.yaml'):
        return name


def get_updated_rhpam_prefix(version):
    return "ibm-bamoe{0}".format(get_shortened_version(version))



def update_image_descriptors(version, confirm):
    """
    Update the rhpam image descriptor to the given version.
    :param version: version to set into the module
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """

    images = []
    for fg in IMAGES_DIR:
        images.append(os.path.join(fg + "/", "image.yaml"))

    print("Image descriptors to be updated: {0}".format(images))

    try:
        for image2update in images:
            with open(image2update) as m:
                # replace all occurrences of shortened version first
                plain = SHORTENED_VERSION_REGEX.sub(get_shortened_version(version), m.read())
                # then update all full version everywhere
                plain = VERSION_REGEX.sub(version, plain)
                data = yaml_loader().load(plain)

                if not confirm:
                    print("Applied changes on module [{0}]: \n".format(image2update))
                    print(plain)
                    print("\n----------------------------------\n")

            if confirm:
                with open(image2update, 'w') as m:
                    yaml_loader().dump(data, m)

    except TypeError:
        raise


def update_image_tag_overrides(version, confirm):
    """
    Update the rhpam image tag overrides to the given version.
    :param version: version to set into the module
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """

    version_regex = re.compile(r'\b\d[.]\d[.]\d.GA')

    tag_o = []
    for fg in IMAGES_DIR:
        tag_o.append(os.path.join(fg + "/", "tag-overrides.yaml"))

    print("Image tag-overrides to be updated: {0}".format(tag_o))

    try:
        for tago2update in tag_o:
            with open(tago2update) as t:
                # update full version everywhere
                plain = version_regex.sub(version + ".GA", t.read())
                data = yaml_loader().load(plain)

                if not confirm:
                    print("Applied changes on module [{0}]: \n".format(tago2update))
                    print(plain)
                    print("\n----------------------------------\n")

            if confirm:
                with open(tago2update, 'w') as t:
                    yaml_loader().dump(data, t)

    except TypeError:
        raise


def update_image_readme(version, confirm):
    """
    Update the rhpam images README file occurrences of the given version.
    :param version: version to set updated
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """
    readmes = []
    for fg in IMAGES_DIR:
        readmes.append(os.path.join(fg + "/", "README.adoc"))

    if confirm:
        for readme in readmes:
            print("Updating the {0} version occurrences to {1} using shortened version".format(readme, version))
            try:
                with open(readme) as ig:
                    # replace all occurrences of shortened version first
                    plain = SHORTENED_VERSION_REGEX.sub(get_shortened_version(version), ig.read())

                with open(readme, 'w') as ig:
                    ig.write(plain)

            except TypeError:
                raise

    else:
        print("Skipping image READMEs {0}".format(readmes))


def update_imagestreams(version, confirm):
    """
    Update the rhpam imagestreams to the given version.
    :param version: version to be set
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """

    print("Updating application imagestreams to version {0}".format(version))

    current_imagestream_name = get_current_imagestream_filename()

    try:
        with open(current_imagestream_name) as imgstr:
            # replace all occurrences of shortened version first
            plain = SHORTENED_VERSION_REGEX.sub(get_shortened_version(version), imgstr.read())
            # then update all full version everywhere
            plain = VERSION_REGEX.sub(version, plain)
            data = yaml_loader().load(plain)
            rhpam_imagestream_updated_name = RHPAM_PREFIX_REGEX.sub(get_updated_rhpam_prefix(version), IMAGESTREAM)

            data['metadata']['name'] = rhpam_imagestream_updated_name

            if not confirm:
                print("Applied changes on imagestream {0}.yaml: \n".format(current_imagestream_name))
                print(data)
                print("\n----------------------------------\n")

        if confirm:
            with open(current_imagestream_name, 'w') as imgstr:
                yaml_loader().dump(data, imgstr)

            # rename imagestream file
#             print("  --> Imagestream file will renamed from {0} to {1}.yaml".format(current_imagestream_name,
#                                                                                     rhpam_imagestream_updated_name))
#             os.renames(current_imagestream_name, rhpam_imagestream_updated_name + ".yaml")

    except TypeError:
        raise


def update_main_readme(version, confirm):
    """
    Update the rhpam main README file occurrences of the given version.
    :param version: version to set updated
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """

    if confirm:
        print("Updating README version occurrences to {0}".format(version))
        try:
            with open("README.md") as readme:
                # replace all occurrences of shortened version first
                plain = SHORTENED_VERSION_REGEX.sub(get_shortened_version(version), readme.read())
                # then update all full version everywhere
                plain = RHPAM_PREFIX_REGEX.sub(get_updated_rhpam_prefix(version), plain)

            with open("README.md", 'w') as readme:
                readme.write(plain)

        except TypeError:
            raise

    else:
        print("Skipping README.md")


def update_circleci_files(version, confirm):
    """
    Update the rhpam circleci files to the given version.
    :param version: version to be set
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """
    circleci_config_file = ".circleci/config.yml"

    print("Updating circleci config.yaml to version {0}".format(version))

    try:
        with open(circleci_config_file) as circ:
            # replace all occurrences of shortened version first - needs to be together, no points, e.g.: 800
            plain = RHPAM_PREFIX_REGEX.sub(get_updated_rhpam_prefix(version), circ.read())

            if not confirm:
                print("Changes applied on {} is:".format(circleci_config_file))
                print(plain)
                print("\n----------------------------------\n")

        if confirm:
            with open(circleci_config_file, 'w') as circ:
                circ.write(plain)

    except TypeError:
        raise


def update_quickstarts_readme(version, confirm):
    """
    Update the rhpam quickstarts README file occurrences of the given version.
    :param version: version to set updated
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """

    readmes = ["quickstarts/library-process/README.md", "quickstarts/router-ext/README.md"]

    if confirm:

        for readme in readmes:

            print("Updating the {0} version occurrences to {1}".format(readme, version))
            try:
                with open(readme) as rd:
                    # replace all occurrences of shortened version first
                    plain = SHORTENED_VERSION_REGEX.sub(get_shortened_version(version), rd.read())
                    # then update all full version everywhere
                    plain = VERSION_REGEX.sub(version, plain)
                    plain = RHPAM_PREFIX_REGEX.sub(get_updated_rhpam_prefix(version), plain)

                with open(readme, 'w') as rd:
                    rd.write(plain)

            except TypeError:
                raise

    else:
        print("Skipping {0}".format(readmes))


def update_cekit_jdbc_extension_images(version, confirm):
    """
    Update the rhpam cekit jdbc extension image to the given version.
    :param version: version to set into the module
    :param confirm: if true will save the changes otherwise will print the proposed changes
    """

    print("Updating CeKit JDBC extension image to version {0}".format(version))

    files_2_update = ['contrib/jdbc/README.md', 'contrib/jdbc/cekit/image.yaml',
                      'contrib/jdbc/cekit/modules/kie-custom-jdbc-driver/base-module.yaml']

    for file in files_2_update:
        print(files_2_update)
        try:
            with open(file) as f:
                print("Updating CeKit JDBC extension image file {0} to version {1}".format(file, version))

                # replace all occurrences of shortened version first
                plain = SHORTENED_VERSION_REGEX.sub(get_shortened_version(version), f.read())
                # then update all full version everywhere
                plain = VERSION_REGEX.sub(version, plain)
                #plain = NO_DOTS_VERSION.sub(get_updated_no_dotes_version(version), plain)

                if not confirm:
                    print("Suggested changes on file {0} to version {1} \n".format(f.name, version))
                    print(plain)
                    print("\n----------------------------------\n")

                if confirm:
                    with open(file, 'w') as f:
                        print("Applied changes on file {0} to version {1} \n".format(f.name, version))
                        f.write(plain)

        except TypeError:
            raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='IBM BAMOE Version Manager')
    parser.add_argument('-v', dest='t_version', help='update everything to the next version')
    parser.add_argument('--confirm', default=False, action='store_true', help='if not set, script will not update the '
                                                                              'rhpam modules. (Dry run)')
    args = parser.parse_args()

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    else:
        # validate if the provided version is valid.
        # e.g. 8.0.1
        pattern = "d.d.d"

        if VERSION_REGEX.match(args.t_version):
            print("Version will be updated to {0}".format(args.t_version))
            update_image_descriptors(args.t_version, args.confirm)
            update_image_tag_overrides(args.t_version, args.confirm)
            update_image_readme(args.t_version, args.confirm)
            update_imagestreams(args.t_version, args.confirm)
            update_main_readme(args.t_version, args.confirm)
            update_circleci_files(args.t_version, args.confirm)
            update_quickstarts_readme(args.t_version, args.confirm)
            update_cekit_jdbc_extension_images(args.t_version, args.confirm)

        else:
            print("Provided version {0} does not match the expected regex - {1}".format(args.t_version, pattern))
