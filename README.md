# Radix

_Radix_ is a set of tools for tracking metadata and provenance of objects.

Metadata includes any information a person wants to attribute to an object,
for example, the author of a book, the condition of a coin, or the company
that printed a poster.

Provenance is a history of ownership and certification for an object. If 
Jill has an object appraised, then sells it to Joe, the provenance
documents the who and when of those two transactions.

_Radix_ seeks to track both, through a system of standardized descriptions
and public key cryptography.

## Proof of Concept

This repository provides proof of concept tools for the _Radix_ system. It is
not production ready, and users should expect it to change significantly!

Also: there are no command line tools. You're flying with alpha quality code, man.

## Radix "Package"

A _package_ corresponds with the object you're describing or tracking. A package
is a directory containing metadata files about the object. Each file belongs to
a person, allowing multiple people to provide information about the object and
it's provenance.

The file that ties everything together within a package is the `manifest.xml` file,
which incorporates other individual files to accommodate piecemeal additions to metadata
and provenance.

## Metadata

Information about an object, from a particular person, is tracked in an XML file.

The structure of the XML file is defined by one (or more) XSD schema definitions,
which can be found in the `schema/` directory, and samples of valid XML files can
be found in the `fixtures/` directory.

Any XML file (including `manifest.xml`) can be signed with a public key crypto
scheme. This is done to ensure that the package can incorporate content that is
readable, but resistant to tampering (such as appraisal information, photographs).

Please see `spec/radix_spec.rb` for examples of how this is implemented. 

## Provenance

It is expected that several people will interact with an object, through purchasing,
certification, or other transactions.