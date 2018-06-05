# sign
> Codesign using an Apple certificate / issuing authority with or without a Mac

A script to extract the necessary certificate and key from Keychain Assistant exported files to codesign a target file with only openSSL.
This allows your to codesign files on the fly from a Linux (or macOS) server.

## Installation
Make sure your Linux or Mac has openssl installed.
Then clone this repo - or just download the `sign` file.
Make sure the file is executable and then just put it somewhere in your `$PATH`.

```
$ chmod +x ./sign && cp ./sign /usr/local/bin/sign
```

## Usage
Run the script without any options or arguments to see usage instructions.

```
$ ./sign

  Usage:
    /usr/local/bin/sign [options] <file-to-sign> <signed-file>

  Options:
    -c <path>   the exported p12 certificate used to codesign
    -p <path>   the signing authority exported as a pem file

  Exporting certificate and authority:
    To retrieve the certificate and private key necessary to codesign a file, open KeyChain Access on your Mac.
    Find the certificate you wish to codesign with, click to expand it to reveal the key it's signed with, and select both.
    Right-click to export both as a single p12 - this is your 'certificate'.
    Find the signing authority and export it as a pem file - this is your 'private key'.
    Pass the p12 certificate as option 'c' and the pem as option 'p'.
    Pass the file to be signed as the next argument, and the output location of the signed file as the next.
```