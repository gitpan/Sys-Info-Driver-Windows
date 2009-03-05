#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <tchar.h>

typedef void (WINAPI *PGNSI)(LPSYSTEM_INFO);
typedef BOOL (WINAPI *PGPI)(DWORD, DWORD, DWORD, DWORD, PDWORD);

MODULE = Sys::Info::Driver::Windows  PACKAGE = Sys::Info::Driver::Windows

int
GetSystemMetrics(index)
    int index
CODE:
    RETVAL = GetSystemMetrics(index);
OUTPUT:
    RETVAL


void
GetSystemInfo()
PREINIT:
    OSVERSIONINFOEX osvi;
    SYSTEM_INFO     si;
    PGNSI           pGNSI;
    //PGPI            pGPI;
    BOOL            bOsVersionInfoEx;
    //DWORD           dwType;
    TCHAR           wProcessorModel         [10];
    TCHAR           wProcessorStepping      [10];
    TCHAR           wProcessorArchitecture2 [64];
PPCODE:
    /* See: http://msdn.microsoft.com/en-us/library/ms724429(VS.85).aspx */
    osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);

    if( !(bOsVersionInfoEx = GetVersionEx ((OSVERSIONINFO *) &osvi)) )
        XSRETURN(1);
 
    // Copy the hardware information to the SYSTEM_INFO structure.
    pGNSI = (PGNSI) GetProcAddress(
                        GetModuleHandle( TEXT("kernel32.dll") ), 
                        "GetNativeSystemInfo"
                    );

    (NULL != pGNSI) ? pGNSI(&si) : GetSystemInfo(&si);

    if ( VER_PLATFORM_WIN32_NT == osvi.dwPlatformId && osvi.dwMajorVersion > 4 ) {
        // We have Win2k or later
        EXTEND(SP, 26);

        switch (si.wProcessorArchitecture) {
            case PROCESSOR_ARCHITECTURE_INTEL:
                lstrcpy(  wProcessorArchitecture2, TEXT("x86") );
                wsprintf( wProcessorModel        , TEXT("%d"), HIBYTE(si.wProcessorRevision) );
                wsprintf( wProcessorStepping     , TEXT("%d"), LOBYTE(si.wProcessorRevision) );
                break;

            case PROCESSOR_ARCHITECTURE_ALPHA: 
                lstrcpy(  wProcessorArchitecture2, TEXT("Alpha"));
                wsprintf( wProcessorModel        , TEXT("%d"), HIBYTE(si.wProcessorRevision) );
                wsprintf( wProcessorStepping     , TEXT("%d"), LOBYTE(si.wProcessorRevision) );
                break;

            case PROCESSOR_ARCHITECTURE_IA64:
                lstrcpy(  wProcessorArchitecture2, TEXT("IA-64"));
                wsprintf( wProcessorModel        , TEXT("%d"), HIBYTE(si.wProcessorRevision) );
                wsprintf( wProcessorStepping     , TEXT("%d"), LOBYTE(si.wProcessorRevision) );
                break;

            case PROCESSOR_ARCHITECTURE_ALPHA64:
                lstrcpy(wProcessorArchitecture2  , TEXT("Alpha64"));
                wsprintf( wProcessorModel        , TEXT("%d"), HIBYTE(si.wProcessorRevision) );
                wsprintf( wProcessorStepping     , TEXT("%d"), LOBYTE(si.wProcessorRevision) );
                break;

            case PROCESSOR_ARCHITECTURE_UNKNOWN:
            default:
                lstrcpy(  wProcessorArchitecture2, TEXT("") );
                lstrcpy(  wProcessorModel        , TEXT("") );
                lstrcpy(  wProcessorStepping     , TEXT("") );
                break;
        }

        // build the info hash
        // Processor
        // TODO: dwAllocationGranularity
        PUSHs( sv_2mortal( newSVpv( "dwNumberOfProcessors"         , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.dwNumberOfProcessors            ) ) );

        PUSHs( sv_2mortal( newSVpv( "dwProcessorType"              , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.dwProcessorType                 ) ) );

        PUSHs( sv_2mortal( newSVpv( "wProcessorArchitecture"       , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.wProcessorArchitecture          ) ) );

        PUSHs( sv_2mortal( newSVpv( "wProcessorLevel"              , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.wProcessorLevel                 ) ) );

        PUSHs( sv_2mortal( newSVpv( "dwActiveProcessorMask"        , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.dwActiveProcessorMask           ) ) );

        PUSHs( sv_2mortal( newSVpv( "wProcessorRevision"           , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.wProcessorRevision              ) ) );

        PUSHs( sv_2mortal( newSVpv( "wProcessorModel"              , 0 ) ) );
        PUSHs( sv_2mortal( newSVpv( wProcessorModel                , 0 ) ) );

        PUSHs( sv_2mortal( newSVpv( "wProcessorStepping"           , 0 ) ) );
        PUSHs( sv_2mortal( newSVpv( wProcessorStepping             , 0 ) ) );

        PUSHs( sv_2mortal( newSVpv( "wProcessorArchitecture2"      , 0 ) ) );
        PUSHs( sv_2mortal( newSVpv( wProcessorArchitecture2        , 0 ) ) );

        // other
        PUSHs( sv_2mortal( newSVpv( "dwOemId"                      , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.dwOemId                         ) ) );

        PUSHs( sv_2mortal( newSVpv( "dwPageSize"                   , 0 ) ) );
        PUSHs( sv_2mortal( newSViv( si.dwPageSize                      ) ) );

        PUSHs( sv_2mortal( newSVpv( "lpMinimumApplicationAddress"  , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.lpMinimumApplicationAddress     ) ) );

        PUSHs( sv_2mortal( newSVpv( "lpMaximumApplicationAddress"  , 0 ) ) );
        PUSHs( sv_2mortal( newSVuv( si.lpMaximumApplicationAddress     ) ) );

    }
    else {
        printf( "GetSystemInfo() can not be run on this version of Windows.\n");
        //XSRETURN(0);
    }
