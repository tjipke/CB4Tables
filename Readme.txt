CB4 Tables
version 2.00 Retail (Normal or Pro)
Copyright (c) MMV Tiriss


DISCLAIMER

Before working with this software, you should protect your data by backing it up
and using a copy of any existing projects for added protection!

Tiriss can be in no way held responsible for any loss of data or any other
failure due to using CB4 Tables.


STARTING

Before using this version of CB4 Tables, be aware that it is a retail product
that you paid for. You are not allowed to distribute it, it's source or parts of
it's source in anyway. After you installed it you can see in the components
popup menu for how many developers you have a license. If you need more licenses
you can always contact us at support@tiriss.com.


E-MAIL

You can mail any problems, suggestions or questions you have about CB4 Tables to
support@tiriss.com.
Please make sure that mail from Tiriss is not catched by your spamfilter!


INSTALL

This archive contains the retail version of CB4 Tables for Delphi 5-2005, Kylix
1-3 and C++Builder 5 and 6. You can extract the archive in a directory of your
choice. If you have a previous version of CB4 Tables, you can overwrite that one
with this one.
You can install the correct version of CB4 Tables by adding the appropriate
package to Delphi, Kylix or C++Builder. Use CB4D#.DPK for Delphi, CB4K#.dpk for
Kylix and CB4C#.BPK for C++Builder (where # is your Delphi, Kylix or C++Builder
version).
SEE KYLIX 3 C++ SECTION below for extra information about installing in Kylix 3
C++ version!

If you have the Pro version of CB4 Tables, you can also use CB4 Tables in VCL
for .Net. In Delphi 2005 you need to install the CB4D2005Net.bdsproj package.
After compiling the package,you need to add the generated dll to the installed
.Net packages in Delphi 2005.

In a non .Net (Win32 or Linux) development the components uses the file
Codebase.pas that is supplied with your CodeBase distribution from sequiter in
the pascal directory. It should be in your Delphi/Kylix search-path to be able
to compile the packages or the source. It is also recommended that you add the
Codebase.pas file to your package!
For usage in C++Builder see the next (C++BUILDER) section.

In the Pro version is for .Net development a Tiriss.Codebase.NetIntf.pas
delivered within the package that wraps CodeBase in a .Net compatible way. You
don't need the .Net package from Sequiter!

When you have installed the package, you'll find two new components in your
component palette ('Data Access'): TCB4Table and TCB4Database.

For the two components to work at all, you have to have a CodeBase c4dll.dll
(version 6.3 or higher!) in your dll-searchpath (preferable in your windows
system directory). For more information on CodeBase contact Sequiter Software
Inc.

If you have an old version of CodeBase then you will need to uncomment the line:
  //{$DEFINE NOVFNULLSUPPORT}
in the CB4Tables.pas file. You will see when this is needed if the product won't
compile: then just remove the '//' from that line (in current version line 16).

Anywhere you would/could normally use a TTable you can now use a TCB4Table!


C++BUILDER

There are some differences in using CB4 Tables to make an executable between
C++Builder and Delphi. In Delphi you have to have a codebase.pas (Supplied by
Sequiter) in your Delphi search path.

For C++Builder you'll have to use the supplied codebase.pas from sequiter and
make a PASCAL VERSION of c4dll.lib (you can use implib supplied by borland).
This also means you will have to use the PASCAL VERSION of the CodeBase dll.


KYLIX

In Kylix make sure you can get the examples supplied by Sequiter's CodeBase for
Kylix working (this would mean that CodeBase is correctly installed). If you
have the examples working then installing the CB4Tables package should be no
problem.


KYLIX 3 C++

If you want to use CodeBase for Kylix in the C++ version of KYLIX 3, you need to
you use the Delphi IDE or compiler to create a package for the C++ IDE. You need
to enable "generate c++ object files" and "include namespaces" in the linker
output options of the CB4K3 package. After you've done that, you still need to
generate a CB4K3.a file. To make that type the following in a shell, when you are
in the directory containing the CB4 Tables source:

        ar rcs CB4K3.a 'cat CB4K3.lsp'

(on some systems you need to do: "ar rcs CB4K3.a CB4K3.lsp", without 'cat')

You can also do the whole process from whithin a shell or script, type:

        dcc -jphnv CB4K31.dpk
        ar rcs CB4K3.a 'cat CB4K3.lsp'

and to generate .HPP files (needed to make projects using CB4 Tables) type:

        dcc -jphnv CB4Tables.pas
        dcc -jphnv CB4Defs.pas


DELPHI 6 and higher, C++BUILDER 6 and KYLIX

If you're using CB4Tables with Codebase Client/Server and you want the standard
Login dialog then you need to add DBLogDlg (or QDBLogDlg for CLX) to your uses
clause. (This change is also required for BDE development in Delphi/BCB 6).


ABOUT TCB4Table

TCB4Table is a replacement of a TTable, using Codebase instead of the BDE. It's
behaviour is almost completely the same as a TTable using a Foxpro, dBase or
Clipper table.

The DatabaseName or Database (but only one of them) property of a TCB4Table can
be used to refer to a TCB4Database so you can refer to tables with just their
filenames and no filepath. You can use a TCB4Table without a TCB4Database by
setting the Tablename property to a complete filepath.

See the enclosed file cb4tableinfo.html and the Delphi help on TTable for more
information about the public interface of TCB4Table.


ABOUT TCB4Database

TCB4Database can be used in two ways: as a container for the path information of
your tables, or to connect to a Codebase server.

See the enclosed file cb4database.html for more information about the public
interface of TCB4Database.


ADDRESSES

Tiriss
http://www.tiriss.com
e-mail: info@tiriss.com
        support@tiriss.com (only for CB4 Tables' customer questions)

Sequiter Software Inc.
http://www.sequiter.com, http://www.codebase.com.


TRADEMARKS

CodeBase is a Trademark of Sequiter Software Inc.
Delphi, Kylix and C++Builder are trademark of Borland International.
Other brand and product names are trademarks of their respective holders.
