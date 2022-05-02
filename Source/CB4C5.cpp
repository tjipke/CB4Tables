//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("CB4C5.res");
USERES("CB4tables.dcr");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("dcldb50.bpi");
USEPACKAGE("dsnide50.bpi");
USEUNIT("CB4reg.pas");
USEPACKAGE("Vcldb50.bpi");
USEUNIT("CB4RecordBuffers.pas");
USEUNIT("CB4Tables.pas");
USELIB("c4dll.lib");
USEUNIT("CB4D5Prop.pas");
USEPACKAGE("vclx50.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
