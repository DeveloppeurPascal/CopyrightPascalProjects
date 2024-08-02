unit uAboutDescriptionText;

interface

const
  CAboutDescriptionEN = '''
This program is intended for Pascal language developers who wish to add a copyright and version comment to the header of their source files (*.pas, *.dpr, *.dpk, *.lpr, ...).

The comments are placed at the beginning of the source file before the standard start of the file content. They are in XML Documentation format with:
- a <summary> explaining what the project or file is about,
- a <remarks> containing license and copyright information,
- <see> (in <remarks>)for links to the code repository and to the project site (if specified).

These comments are supported in Delphi. They will not cause problems in other compilers, interpreters and editors.
*****************
* Publisher info

This application was developed by Patrick Prémartin in Delphi.

It is published by OLF SOFTWARE, a company registered in Paris (France) under the reference 439521725.

****************
* Personal data

This program is autonomous in its current version. It does not depend on the Internet and communicates nothing to the outside world.

We have no knowledge of what you do with it.

No information about you is transmitted to us or to any third party.

We use no cookies, no tracking, no stats on your use of the application.

***************
* User support

If you have any questions or require additional functionality, please leave us a message on the application''s website or on its code repository.

To find out more, visit https://copyrightpascalprojects.olfsoftware.fr/
''';

implementation

end.
