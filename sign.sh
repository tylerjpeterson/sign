#!/usr/bin/env bash

# Codesign using Apple certificates without a Mac
# (requires openssl)
#
# Open KeyChain Access on your Mac
# Find the certificate you wish to codesign with, then
# expand it to reveal the key it's signed with, select
# both, and right-click to export both as a single p12 -
# this is your "certificate"
#
# Find the signing authority and export it as a pem file -
# this is your "private key"
R=$(echo -en '\033[0m')
B=$(echo -en '\033[01;37m')

# Usage information / exporting instructions
usage() {
	echo -e "$B\n  Usage:$R" 1>&2;
	echo -e "    $0 [options] <file-to-sign> <signed-file>\n" 1>&2;
	echo -e "$B  Options:$R" 1>&2;
	echo -e "    -c <path>   the exported p12 certificate used to codesign" 1>&2;
	echo -e "    -p <path>   the signing authority exported as a pem file\n" 1>&2;
	echo -e "$B  Exporting certificate and authority:$R" 1>&2;
	echo -e "    To retrieve the certificate and private key necessary to codesign a file, open KeyChain Access on your Mac." 1>&2;
	echo -e "    Find the certificate you wish to codesign with, click to expand it to reveal the key it's signed with, and select both." 1>&2;
	echo -e "    Right-click to export both as a single p12 - this is your 'certificate'." 1>&2;
	echo -e "    Find the signing authority and export it as a pem file - this is your 'private key'." 1>&2;
	echo -e "    Pass the p12 certificate as option 'c' and the pem as option 'p'." 1>&2;
	echo -e "    Pass the file to be signed as the next argument, and the output location of the signed file as the next." 1>&2;
	echo -e "\n" 1>&2;
	exit 1;
}

# Parse arguments / options
while getopts ":c:p:i:o:" opt; do
	case ${opt} in
		c ) CERT=$OPTARG ;;
		p ) PRIV=$OPTARG ;;
		\? ) echo "Invalid option: $OPTARG" 1>&2 ;;
		: ) echo "Invalid option: $OPTARG requires an argument" 1>&2 ;;
	esac
done
shift $((OPTIND -1))

[ "${1:-}" = "--" ] && shift

# File to sign
IN=$1

# Location to save signed output file
OUT=$2

# If any options are not set, output usage and exit
if [ -z "${IN}" ] || [ -z "${OUT}" ] || [ -z "${CERT}" ] || [ -z "${PRIV}" ]; then
	usage
fi

# Temporary directory
TMP="__tmp"

# Create temp directory to store extracted key and certificate
mkdir -p "$TMP"

# Extract the private key from the exported cert
openssl pkcs12 \
	-in "$CERT" \
	-out "$TMP/private.pem" \
	-nodes \
	-nocerts \
	-password pass:""

# Extract the certificate from the exported cert
openssl pkcs12 \
	-in "$CERT" \
	-out "$TMP/certificate.pem" \
	-nodes \
	-nokeys \
	-password pass:""

# Sign the specified file using the extracted key and certificate
openssl smime \
	-sign \
	-in "$IN" \
	-out "$OUT" \
	-signer "$TMP/certificate.pem" \
	-inkey "$TMP/private.pem" \
	-certfile "$PRIV" \
	-outform der \
	-nodetach

# Clean up the tmp directory
rm -rf "$TMP"
