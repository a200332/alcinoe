{*************************************************************
www:          http://sourceforge.net/projects/alcinoe/              
svn:          https://alcinoe.svn.sourceforge.net/svnroot/alcinoe
Author(s):    St�phane Vander Clock (svanderclock@arkadia.com)
Sponsor(s):   Arkadia SA (http://www.arkadia.com)

product:      ALSqlite3Client
Version:      1.00

Description:  An object to query Sqlite3 database and get
              the result In Xml stream

              SQLite is a software library that implements a self-contained,
              serverless, zero-configuration, transactional SQL database
              engine. The source code for SQLite is in the public domain and
              is thus free for use for any purpose, commercial or private.
              SQLite is the most widely deployed SQL database engine
              in the world.

Legal issues: Copyright (C) 1999-2010 by Arkadia Software Engineering

              This software is provided 'as-is', without any express
              or implied warranty.  In no event will the author be
              held liable for any  damages arising from the use of
              this software.

              Permission is granted to anyone to use this software
              for any purpose, including commercial applications,
              and to alter it and redistribute it freely, subject
              to the following restrictions:

              1. The origin of this software must not be
                 misrepresented, you must not claim that you wrote
                 the original software. If you use this software in
                 a product, an acknowledgment in the product
                 documentation would be appreciated but is not
                 required.

              2. Altered source versions must be plainly marked as
                 such, and must not be misrepresented as being the
                 original software.

              3. This notice may not be removed or altered from any
                 source distribution.

              4. You must register this software by sending a picture
                 postcard to the author. Use a nice stamp and mention
                 your name, street address, EMail address and any
                 comment you like to say.

Know bug :

History :

Link :        http://www.sqlite.org/

* Please send all your feedback to svanderclock@arkadia.com
* If you have downloaded this source from a website different from
  sourceforge.net, please get the last version on http://sourceforge.net/projects/alcinoe/
* Please, help us to keep the development of these components free by 
  voting on http://www.arkadia.com/html/alcinoe_like.html
**************************************************************}
unit AlSqlite3Client;

interface

uses Windows,
     SysUtils,
     classes,
     Contnrs,
     SyncObjs,
     AlXmlDoc,
     AlSqlite3Wrapper;

Type

  {-------------------------------------------------------------------------}
  TalSqlite3ClientSelectDataOnNewRowFunct = Procedure(XMLRowData: TalXmlNode;
                                                      ViewTag: String;
                                                      ExtData: Pointer;
                                                      Var Continue: Boolean);

  {--------------------------------}
  EALSqlite3Error = class(Exception)
  private
    FErrorCode: Integer;
  public
    constructor Create(aErrorMsg: string; aErrorCode: Integer); overload;
    property ErrorCode: Integer read FErrorCode;
  end;

  {------------------------------------}
  TalSqlite3ClientSelectDataSQL = record
    SQL: String;
    RowTag: String;
    ViewTag: String;
    Skip: integer;
    First: Integer;
  end;
  TalSqlite3ClientSelectDataSQLs = array of TalSqlite3ClientSelectDataSQL;

  {------------------------------------}
  TalSqlite3ClientUpdateDataSQL = record
    SQL: String;
  end;
  TalSqlite3ClientUpdateDataSQLs = array of TalSqlite3ClientUpdateDataSQL;

  {-------------------------------}
  TalSqlite3Client = Class(Tobject)
  Private
    fLibrary: TALSqlite3Library;
    FownLibrary: Boolean;
    fSqlite3: PSQLite3;
    fNullString: String;
    finTransaction: Boolean;
    function  GetConnected: Boolean;
    function  GetInTransaction: Boolean;
  Protected
    procedure CheckAPIError(Error: Boolean);
    Function  GetFieldValue(aSqlite3stmt: PSQLite3Stmt;
                            aIndex: Integer;
                            aFormatSettings: TformatSettings): String;
    procedure initObject; virtual;
  Public
    Constructor Create(const lib: String = 'sqlite3.dll'; const initializeLib: Boolean = True); overload; virtual;
    Constructor Create(lib: TALSqlite3Library); overload; virtual;
    Destructor Destroy; Override;
    procedure config(Option: Integer);
    procedure initialize; //can not be put in the create because config can/must be call prior initialize
    procedure shutdown;   //can not be put in the create because config can/must be call after shutdown
    procedure enable_shared_cache(enable: boolean);
    function  soft_heap_limit64(n: int64): int64;
    Procedure Connect(DatabaseName: String;
                      const flags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
    Procedure Disconnect;
    Procedure TransactionStart;
    Procedure TransactionCommit;
    Procedure TransactionRollback;
    Procedure SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                         XMLDATA: TalXMLNode;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: String;
                         Skip: integer;
                         First: Integer;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: String;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: String;
                         RowTag: String;
                         Skip: integer;
                         First: Integer;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: String;
                         RowTag: String;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings); overload;
    Procedure SelectData(SQL: String;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings); overload;
    procedure UpdateData(SQLs: TalSqlite3ClientUpdateDataSQLs); overload;
    procedure UpdateData(SQL: TalSqlite3ClientUpdateDataSQL); overload;
    procedure UpdateData(SQLs: Tstrings); overload;
    procedure UpdateData(SQL: String); overload;
    procedure UpdateData(SQLs: array of String); overload;
    Property  Connected: Boolean Read GetConnected;
    Property  InTransaction: Boolean read GetInTransaction;
    Property  NullString: String Read fNullString Write fNullString;
    property  Lib: TALSqlite3Library read FLibrary;
  end;

  {------------------------------------------------}
  TalSqlite3ConnectionPoolContainer = Class(TObject)
    ConnectionHandle: PSQLite3;
    LastAccessDate: int64;
  End;

  {---------------------------------------------}
  TalSqlite3ConnectionPoolClient = Class(Tobject)
  Private
    FLibrary: TALSqlite3Library;
    FownLibrary: Boolean;
    FConnectionPool: TObjectList;
    FConnectionPoolCS: TCriticalSection;
    FDatabaseRWCS: TMultiReadExclusiveWriteSynchronizer;
    FDatabaseWriteLocked: Boolean;
    FWorkingConnectionCount: Integer;
    FReleasingAllconnections: Boolean;
    FLastConnectionGarbage: Int64;
    FConnectionMaxIdleTime: integer;
    FDataBaseName: String;
    FOpenConnectionFlags: integer;
    FOpenConnectionPragmaStatements: Tstrings;
    FNullString: String;
  Protected
    procedure CheckAPIError(ConnectionHandle: PSQLite3; Error: Boolean);
    function  GetDataBaseName: String; virtual;
    Function  GetFieldValue(aSqlite3stmt: PSQLite3Stmt;
                            aIndex: Integer;
                            aFormatSettings: TformatSettings): String; virtual;
    procedure initObject(aDataBaseName: String;
                         const aOpenConnectionFlags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
                         const aOpenConnectionPragmaStatements: String = ''); virtual;
    Function  AcquireConnection(const readonly: boolean = False): PSQLite3; virtual;
    Procedure ReleaseConnection(var ConnectionHandle: PSQLite3;
                                const CloseConnection: Boolean = False); virtual;
  Public
    Constructor Create(aDataBaseName: String;
                       const aOpenConnectionFlags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
                       const aOpenConnectionPragmaStatements: String = '';
                       const alib: String = 'sqlite3.dll';
                       const initializeLib: Boolean = True); overload; virtual;
    Constructor Create(aDataBaseName: String;
                       alib: TALSqlite3Library;
                       const aOpenConnectionFlags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
                       const aOpenConnectionPragmaStatements: String = ''); overload; virtual;
    Destructor  Destroy; Override;
    procedure config(Option: Integer);
    procedure initialize; //can not be put in the create because config can/must be call prior initialize
    procedure shutdown;   //can not be put in the create because config can/must be call after shutdown
    procedure enable_shared_cache(enable: boolean);
    function  soft_heap_limit64(n: int64): int64;
    Procedure ReleaseAllConnections(Const WaitWorkingConnections: Boolean = True); virtual;
    Procedure TransactionStart(Var ConnectionHandle: PSQLite3; const ReadOnly: boolean = False); virtual;
    Procedure TransactionCommit(var ConnectionHandle: PSQLite3;
                                const CloseConnection: Boolean = False); virtual;
    Procedure TransactionRollback(var ConnectionHandle: PSQLite3;
                                  const CloseConnection: Boolean = False); virtual;
    Procedure SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                         XMLDATA: TalXMLNode;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: String;
                         Skip: integer;
                         First: Integer;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: String;
                         OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                         ExtData: Pointer;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: String;
                         RowTag: String;
                         Skip: integer;
                         First: Integer;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: String;
                         RowTag: String;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Procedure SelectData(SQL: String;
                         XMLDATA: TalXMLNode;
                         FormatSettings: TformatSettings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    procedure UpdateData(SQLs: TalSqlite3ClientUpdateDataSQLs;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    procedure UpdateData(SQL: TalSqlite3ClientUpdateDataSQL;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    procedure UpdateData(SQLs: Tstrings;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    procedure UpdateData(SQL: String;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    procedure UpdateData(SQLs: array of String;
                         const ConnectionHandle: PSQLite3 = nil); overload; virtual;
    Function  ConnectionCount: Integer;
    Function  WorkingConnectionCount: Integer;
    property  DataBaseName: String read GetDataBaseName;
    property  ConnectionMaxIdleTime: integer read FConnectionMaxIdleTime write fConnectionMaxIdleTime;
    Property  NullString: String Read fNullString Write fNullString;
    property  Lib: TALSqlite3Library read FLibrary;
  end;

implementation

Uses ALWindows,
     AlFcnString;

///////////////////////////
///// EALSqlite3Error /////
///////////////////////////

{*************************************************************************}
constructor EALSqlite3Error.Create(aErrorMsg: string; aErrorCode: Integer);
begin
  fErrorCode := aErrorCode;
  inherited create(aErrorMsg);
end;



////////////////////////////
///// TalSqlite3Client /////
////////////////////////////

{**********************************************}
function TalSqlite3Client.GetConnected: Boolean;
begin
  result := assigned(fSQLite3);
end;

{**************************************************}
function TalSqlite3Client.GetInTransaction: Boolean;
begin
  result := finTransaction;
end;

{*******************************************************}
procedure TalSqlite3Client.CheckAPIError(Error: Boolean);
Begin
  if Error then begin
    if assigned(Fsqlite3) then raise EALSqlite3Error.Create(fLibrary.sqlite3_errmsg(Fsqlite3), fLibrary.sqlite3_errcode(Fsqlite3)) // !! take care that sqlite3_errmsg(Fsqlite3) return an UTF8 !!
    else raise EALSqlite3Error.Create('Sqlite3 error', -1);
  end;
end;

{*****************************************************************}
function TalSqlite3Client.GetFieldValue(aSqlite3stmt: PSQLite3Stmt;
                                        aIndex: Integer;
                                        aFormatSettings: TformatSettings): String;
begin
  Case FLibrary.sqlite3_column_type(aSqlite3stmt, aIndex) of
    SQLITE_FLOAT: Result := Floattostr(FLibrary.sqlite3_column_double(aSqlite3stmt, aIndex), aFormatSettings);
    SQLITE_INTEGER,
    SQLITE3_TEXT: result :=  String(FLibrary.sqlite3_column_text(aSqlite3stmt, aIndex)); // Strings returned by sqlite3_column_text(), even empty strings, are always zero terminated
                                                                                         // Note: what's happen if #0 is inside the string ?
    SQLITE_NULL: result := fNullString;
    else raise Exception.Create('Unsupported column type');
  end;
end;

{************************************}
procedure TalSqlite3Client.initObject;
begin
  fSqlite3 := nil;
  finTransaction := False;
  fNullString := '';
end;

{**********************************************************************************************************}
constructor TalSqlite3Client.Create(const lib: String = 'sqlite3.dll'; const initializeLib: Boolean = True);
begin
  fLibrary := TALSqlite3Library.Create;
  try
    fLibrary.Load(lib, initializeLib);
    FownLibrary := True;
    initObject;
  Except
    fLibrary.free;
    raise;
  end;
end;

{**********************************************************}
constructor TalSqlite3Client.Create(lib: TALSqlite3Library);
begin
  fLibrary := lib;
  FownLibrary := False;
  initObject;
end;

{**********************************}
destructor TalSqlite3Client.Destroy;
begin
  If Connected then disconnect;
  if FownLibrary then fLibrary.Free;
  inherited;
end;

{*********************************************************************************
The sqlite3_config() interface is used to make global configuration changes to SQLite
in order to tune SQLite to the specific needs of the application.

The sqlite3_config() interface is not threadsafe. The application must insure that
no other SQLite interfaces are invoked by other threads while sqlite3_config()
is running. Furthermore, sqlite3_config() may only be invoked prior to library
initialization using sqlite3_initialize() or after shutdown by sqlite3_shutdown().

SQLITE_CONFIG_SINGLETHREAD
  There are no arguments to this option. This option sets the threading mode to
  Single-thread. In other words, it disables all mutexing and puts SQLite into a mode
  where it can only be used by a single thread. If SQLite is compiled with the
  SQLITE_THREADSAFE=0 compile-time option then it is not possible to change the
  threading mode from its default value of Single-thread and so sqlite3_config()
  will return SQLITE_ERROR if called with the SQLITE_CONFIG_SINGLETHREAD configuration option.

SQLITE_CONFIG_MULTITHREAD
  There are no arguments to this option. This option sets the threading mode to
  Multi-thread. In other words, it disables mutexing on database connection and
  prepared statement objects. The application is responsible for serializing
  access to database connections and prepared statements. But other mutexes are
  enabled so that SQLite will be safe to use in a multi-threaded environment as long
  as no two threads attempt to use the same database connection at the same time.
  If SQLite is compiled with the SQLITE_THREADSAFE=0 compile-time option then it
  is not possible to set the Multi-thread threading mode and sqlite3_config() will
  return SQLITE_ERROR if called with the SQLITE_CONFIG_MULTITHREAD configuration option.

SQLITE_CONFIG_SERIALIZED
  There are no arguments to this option. This option sets the threading mode to
  Serialized. In other words, this option enables all mutexes including the recursive
  mutexes on database connection and prepared statement objects. In this mode (which
  is the default when SQLite is compiled with SQLITE_THREADSAFE=1) the SQLite library
  will itself serialize access to database connections and prepared statements so that
  the application is free to use the same database connection or the same prepared
  statement in different threads at the same time. If SQLite is compiled with the
  SQLITE_THREADSAFE=0 compile-time option then it is not possible to set the Serialized
  threading mode and sqlite3_config() will return SQLITE_ERROR if called with the
  SQLITE_CONFIG_SERIALIZED configuration option.}
procedure TalSqlite3Client.config(Option: Integer);
begin
  CheckAPIError(FLibrary.sqlite3_config(Option) <> SQLITE_OK);
end;

{************************************}
procedure TalSqlite3Client.initialize;
begin
  CheckAPIError(FLibrary.sqlite3_initialize <> SQLITE_OK);
end;

{**********************************}
procedure TalSqlite3Client.shutdown;
begin
  CheckAPIError(FLibrary.sqlite3_shutdown <> SQLITE_OK);
end;

{**************************************************************}
procedure TalSqlite3Client.enable_shared_cache(enable: boolean);
begin
  if enable then CheckAPIError(FLibrary.sqlite3_enable_shared_cache(1) <> SQLITE_OK)
  else CheckAPIError(FLibrary.sqlite3_enable_shared_cache(0) <> SQLITE_OK);
end;

{***********************************************************
The sqlite3_soft_heap_limit64() interface sets and/or queries the soft limit on
the amount of heap memory that may be allocated by SQLite. SQLite strives to keep
heap memory utilization below the soft heap limit by reducing the number of
pages held in the page cache as heap memory usages approaches the limit. The soft
heap limit is "soft" because even though SQLite strives to stay below the limit,
it will exceed the limit rather than generate an SQLITE_NOMEM error. In other words,
the soft heap limit is advisory only.

The return value from sqlite3_soft_heap_limit64() is the size of the soft heap
limit prior to the call.}
function TalSqlite3Client.soft_heap_limit64(n: int64): int64;
begin
  result := Flibrary.sqlite3_soft_heap_limit64(n);
end;

{**********************************************************
The flags parameter to sqlite3_open_v2() can take one of the following three values, optionally combined with
the SQLITE_OPEN_NOMUTEX, SQLITE_OPEN_FULLMUTEX, SQLITE_OPEN_SHAREDCACHE, and/or SQLITE_OPEN_PRIVATECACHE flags:

  SQLITE_OPEN_READONLY
    The database is opened in read-only mode. If the database does not already exist, an error is returned.
  SQLITE_OPEN_READWRITE
    The database is opened for reading and writing if possible, or reading only if the file is write protected by the
    operating system. In either case the database must already exist, otherwise an error is returned.
  SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
    The database is opened for reading and writing, and is creates it if it does not already exist. This is the
    behavior that is always used for sqlite3_open() and sqlite3_open16().

If the 3rd parameter to sqlite3_open_v2() is not one of the combinations shown above or one of the combinations
shown above combined with the SQLITE_OPEN_NOMUTEX, SQLITE_OPEN_FULLMUTEX, SQLITE_OPEN_SHAREDCACHE and/or
SQLITE_OPEN_PRIVATECACHE flags, then the behavior is undefined.

If the SQLITE_OPEN_NOMUTEX flag is set, then the database connection opens in the multi-thread
threading mode as long as the single-thread mode has not been set at compile-time or start-time. If the
SQLITE_OPEN_FULLMUTEX flag is set then the database connection opens in the serialized threading mode
unless single-thread was previously selected at compile-time or start-time. The SQLITE_OPEN_SHAREDCACHE flag
causes the database connection to be eligible to use shared cache mode, regardless of whether or not shared
cache is enabled using sqlite3_enable_shared_cache(). The SQLITE_OPEN_PRIVATECACHE flag causes the
database connection to not participate in shared cache mode even if it is enabled.

If the filename is ":memory:", then a private, temporary in-memory database is created for the connection.
This in-memory database will vanish when the database connection is closed. Future versions of
SQLite might make use of additional special filenames that begin with the ":" character. It is recommended
that when a database filename actually does begin with a ":" character you should prefix the filename
with a pathname such as "./" to avoid ambiguity.

If the filename is an empty string, then a private, temporary on-disk database will be created.
This private database will be automatically deleted as soon as the database connection is closed.}
procedure TalSqlite3Client.connect(DatabaseName: String;
                                   const flags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
begin
  if connected then raise Exception.Create('Already connected');
  Try
    CheckAPIError(fLibrary.sqlite3_open_v2(PAnsiChar(DatabaseName), FSqlite3, flags, nil) <> SQLITE_OK);
  Except
    //A database connection handle is usually returned in *ppDb, even if an error occurs.
    //Whether or not an error occurs when it is opened, resources associated with the
    //database connection handle should be released by passing it to sqlite3_close()
    //when it is no longer required
    if assigned(FSqlite3) then fLibrary.sqlite3_close(FSqlite3);
    FSqlite3 := nil;
    Raise;
  End;
end;

{****************************************************************************************
{Applications must finalize all prepared statements and close all BLOB handles associated
 with the sqlite3 object prior to attempting to close the object. If sqlite3_close() is
 called on a database connection that still has outstanding prepared statements or
 BLOB handles, then it returns SQLITE_BUSY.
 If sqlite3_close() is invoked while a transaction is open, the transaction is
 automatically rolled back.}
procedure TalSqlite3Client.Disconnect;
begin
  If not connected then exit;
  if InTransaction then TransactionRollback;
  try
    FLibrary.sqlite3_close(FSqlite3);
  Except
    //Disconnect must be a "safe" procedure because it's mostly called in
    //finalization part of the code that it is not protected
    //that the bulsheet of SQLite3 to answer SQLITE_BUSY instead of free
    //everything
  End;
  FSqlite3 := Nil;
end;

{******************************************}
procedure TalSqlite3Client.TransactionStart;
begin

  //Error if we are not connected
  If not connected then raise Exception.Create('Not connected');
  if InTransaction then raise Exception.Create('Another transaction is active');

  //execute the query
  UpdateData('BEGIN TRANSACTION');
  finTransaction := True;

end;

{*******************************************}
procedure TalSqlite3Client.TransactionCommit;
begin

  //Error if we are not connected
  if not InTransaction then raise Exception.Create('No active transaction to commit');

  //Execute the Query
  UpdateData('COMMIT TRANSACTION');
  finTransaction := False;

end;

{*********************************************}
procedure TalSqlite3Client.TransactionRollback;
begin

  //Error if we are not connected
  if not InTransaction then raise Exception.Create('No active transaction to rollback');

  //Execute the Query
  Try
    UpdateData('ROLLBACK TRANSACTION');
  Except
    //some error can happen if the network go down for exemple
    //i don't really know what to do in this case of error
    //but what else we can do ? commit => exept => rollback => except ???
  End;
  finTransaction := False;

end;

{*************************************************************************}
procedure TalSqlite3Client.SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                                      XMLDATA: TalXMLNode;
                                      OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                      ExtData: Pointer;
                                      FormatSettings: TformatSettings);
Var astmt: PSQLite3Stmt;
    aStepResult: integer;
    aColumnCount: Integer;
    aColumnIndex: integer;
    aColumnNames: Array of String;
    aNewRec: TalXmlNode;
    aValueRec: TalXmlNode;
    aViewRec: TalXmlNode;
    aSQLsindex: integer;
    aRecIndex: integer;
    aRecAdded: integer;
    aContinue: Boolean;
    aXmlDocument: TalXmlDocument;
    aUpdateRowTagByFieldValue: Boolean;

begin

  //Error if we are not connected
  If not connected then raise Exception.Create('Not connected');

  //clear the XMLDATA
  if assigned(XMLDATA) then begin
    XMLDATA.ChildNodes.Clear;
    aXmlDocument := Nil;
  end
  else begin
    aXmlDocument := ALCreateEmptyXMLDocument('root');
    XMLDATA := aXmlDocument.DocumentElement;
  end;
  
  try

    {loop on all the SQL}
    For aSQLsindex := 0 to length(SQLs) - 1 do begin

      //prepare the query
      astmt := nil;
      CheckAPIError(FLibrary.sqlite3_prepare_v2(FSqlite3, Pchar(SQLs[aSQLsindex].SQL), length(SQLs[aSQLsindex].SQL), astmt, nil) <> SQLITE_OK);
      Try

        //Return the number of columns in the result set returned by the
        //prepared statement. This routine returns 0 if pStmt is an SQL statement
        //that does not return data (for example an UPDATE).
        aColumnCount := FLibrary.sqlite3_column_count(astmt);

        //init the aColumnNames array
        setlength(aColumnNames,aColumnCount);
        For aColumnIndex := 0 to aColumnCount - 1 do
          aColumnNames[aColumnIndex] := FLibrary.sqlite3_column_name(astmt, aColumnIndex);

        //init the aViewRec
        if (SQLs[aSQLsindex].ViewTag <> '') and (not assigned(aXmlDocument)) then aViewRec := XMLdata.AddChild(SQLs[aSQLsindex].ViewTag)
        else aViewRec := XMLdata;

        //init aUpdateRowTagByFieldValue
        if AlPos('&>',SQLs[aSQLsindex].RowTag) = 1 then begin
          delete(SQLs[aSQLsindex].RowTag, 1, 2);
          aUpdateRowTagByFieldValue := True;
        end
        else aUpdateRowTagByFieldValue := False;

        //loop throught all row
        aRecIndex := 0;
        aRecAdded := 0;
        while True do begin

          //retrieve the next row
          aStepResult := FLibrary.sqlite3_step(astmt);

          //break if no more row
          if aStepResult = SQLITE_DONE then break

          //download the row
          else if aStepResult = SQLITE_ROW then begin

            //process if > Skip
            inc(aRecIndex);
            If aRecIndex > SQLs[aSQLsindex].Skip then begin

              //stop if no row are requested
              If (SQLs[aSQLsindex].First = 0) then break;

              //init NewRec
              if (SQLs[aSQLsindex].RowTag <> '') and (not assigned(aXmlDocument)) then aNewRec := aViewRec.AddChild(SQLs[aSQLsindex].RowTag)
              Else aNewRec := aViewRec;

              //loop throught all column
              For aColumnIndex := 0 to aColumnCount - 1 do begin
                aValueRec := aNewRec.AddChild(ALlowercase(aColumnNames[aColumnIndex]));
                aValueRec.Text := GetFieldValue(astmt,
                                                aColumnIndex,
                                                FormatSettings);
                if aUpdateRowTagByFieldValue and (aValueRec.NodeName=aNewRec.NodeName) then aNewRec.NodeName := ALLowerCase(aValueRec.Text);
              end;

              //handle OnNewRowFunct
              if assigned(OnNewRowFunct) then begin
                aContinue := True;
                OnNewRowFunct(aNewRec, SQLs[aSQLsindex].ViewTag, ExtData, aContinue);
                if Not aContinue then Break;
              end;

              //free the node if aXmlDocument
              if assigned(aXmlDocument) then aXmlDocument.DocumentElement.ChildNodes.Clear;

              //handle the First
              inc(aRecAdded);
              If (SQLs[aSQLsindex].First >= 0) and (aRecAdded >= SQLs[aSQLsindex].First) then Break;

            end;

          end

          //misc error, raise an exception
          else CheckAPIError(True);

        end;

      Finally
        //free the memory used by the API
        CheckAPIError(FLibrary.sqlite3_finalize(astmt) <> SQLITE_OK);
      End;

    End;

  Finally
    if assigned(aXmlDocument) then aXmlDocument.free;
  End;

end;

{***********************************************************************}
procedure TalSqlite3Client.SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                                      OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                      ExtData: Pointer;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0] := Sql;
  SelectData(aSelectDataSQLs,
             nil,
             OnNewRowFunct,
             ExtData,
             FormatSettings);
end;

{************************************************}
procedure TalSqlite3Client.SelectData(SQL: String;
                                      Skip: Integer;
                                      First: Integer;
                                      OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                      ExtData: Pointer;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := '';
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := Skip;
  aSelectDataSQLs[0].First := First;
  SelectData(aSelectDataSQLs,
             nil,
             OnNewRowFunct,
             ExtData,
             FormatSettings);
end;

{************************************************}
procedure TalSqlite3Client.SelectData(SQL: String;
                                      OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                      ExtData: Pointer;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := '';
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := -1;
  aSelectDataSQLs[0].First := -1;
  SelectData(aSelectDataSQLs,
             nil,
             OnNewRowFunct,
             ExtData,
             FormatSettings);
end;

{*************************************************************************}
procedure TalSqlite3Client.SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                                      XMLDATA: TalXMLNode;
                                      FormatSettings: TformatSettings);
begin

  SelectData(SQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings);

end;

{***********************************************************************}
procedure TalSqlite3Client.SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                                      XMLDATA: TalXMLNode;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0] := Sql;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings);
end;

{************************************************}
procedure TalSqlite3Client.SelectData(SQL: String;
                                      RowTag: String;
                                      Skip: Integer;
                                      First: Integer;
                                      XMLDATA: TalXMLNode;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := RowTag;
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := Skip;
  aSelectDataSQLs[0].First := First;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings);
end;

{************************************************}
procedure TalSqlite3Client.SelectData(SQL: String;
                                      RowTag: String;
                                      XMLDATA: TalXMLNode;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := RowTag;
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := -1;
  aSelectDataSQLs[0].First := -1;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings);
end;

{************************************************}
procedure TalSqlite3Client.SelectData(SQL: String;
                                      XMLDATA: TalXMLNode;
                                      FormatSettings: TformatSettings);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := '';
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := -1;
  aSelectDataSQLs[0].First := -1;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings);
end;

{**************************************************************************}
procedure TalSqlite3Client.UpdateData(SQLs: TalSqlite3ClientUpdateDataSQLs);
Var astmt: PSQLite3Stmt;
    aSQLsindex: integer;
begin

  //exit if no SQL
  if length(SQLs) = 0 then Exit;

  //Error if we are not connected
  If not connected then raise Exception.Create('Not connected');

  {loop on all the SQL}
  For aSQLsindex := 0 to length(SQLs) - 1 do begin

    //prepare the query
    CheckAPIError(FLibrary.sqlite3_prepare_v2(FSqlite3, Pchar(SQLs[aSQLsindex].SQL), length(SQLs[aSQLsindex].SQL), astmt, nil) <> SQLITE_OK);
    Try

      //retrieve the next row
      CheckAPIError(not (FLibrary.sqlite3_step(astmt) in [SQLITE_DONE, SQLITE_ROW]));

    Finally
      //free the memory used by the API
      CheckAPIError(FLibrary.sqlite3_finalize(astmt) <> SQLITE_OK);
    End;

  end;

end;

{************************************************************************}
procedure TalSqlite3Client.UpdateData(SQL: TalSqlite3ClientUpdateDataSQL);
Var aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
begin
  setlength(aUpdateDataSQLs,1);
  aUpdateDataSQLs[0] := SQL;
  UpdateData(aUpdateDataSQLs);
end;

{****************************************************}
procedure TalSqlite3Client.UpdateData(SQLs: Tstrings);
Var aSQLsindex : integer;
    aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
begin
  setlength(aUpdateDataSQLs,SQLs.Count);
  For aSQLsindex := 0 to SQLs.Count - 1 do begin
    aUpdateDataSQLs[aSQLsindex].SQL := SQLs[aSQLsindex];
  end;
  UpdateData(aUpdateDataSQLs);
end;

{*************************************************}
procedure TalSqlite3Client.UpdateData(SQL: String);
Var aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
begin
  setlength(aUpdateDataSQLs,1);
  aUpdateDataSQLs[0].SQL := SQL;
  UpdateData(aUpdateDataSQLs);
end;

{***********************************************************}
procedure TalSqlite3Client.UpdateData(SQLs: array of String);
Var aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
    i: integer;
begin
  setlength(aUpdateDataSQLs,length(SQLs));
  for I := 0 to length(SQLs) - 1 do begin
    aUpdateDataSQLs[i].SQL := SQLs[i];
  end;
  UpdateData(aUpdateDataSQLs);
end;




////////////////////////////////////
///// TalSqlite3ConnPoolClient /////
////////////////////////////////////

{*************************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.CheckAPIError(ConnectionHandle: PSQLite3; Error: Boolean);
begin
  if Error then begin
    if assigned(ConnectionHandle) then raise EALSqlite3Error.Create(fLibrary.sqlite3_errmsg(ConnectionHandle), fLibrary.sqlite3_errcode(ConnectionHandle)) // !! take care that sqlite3_errmsg(Fsqlite3) return an UTF8 !!
    else raise EALSqlite3Error.Create('Sqlite3 error', -1);
  end
end;

{**************************************************************}
function TalSqlite3ConnectionPoolClient.GetDataBaseName: String;
begin
  result := FdatabaseName;
end;

{*******************************************************************************}
function TalSqlite3ConnectionPoolClient.GetFieldValue(aSqlite3stmt: PSQLite3Stmt;
                                                      aIndex: Integer;
                                                      aFormatSettings: TformatSettings): String;
begin
  Case FLibrary.sqlite3_column_type(aSqlite3stmt, aIndex) of
    SQLITE_FLOAT: Result := Floattostr(FLibrary.sqlite3_column_double(aSqlite3stmt, aIndex), aFormatSettings);
    SQLITE_INTEGER,
    SQLITE3_TEXT: result :=  String(FLibrary.sqlite3_column_text(aSqlite3stmt, aIndex)); // Strings returned by sqlite3_column_text(), even empty strings, are always zero terminated
                                                                                             // Note: what's happen if #0 is inside the string ?
    SQLITE_NULL: result := fNullString;
    else raise Exception.Create('Unsupported column type');
  end;
end;

{************************************************************************}
procedure TalSqlite3ConnectionPoolClient.initObject(aDataBaseName: String;
                                                    const aOpenConnectionFlags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
                                                    const aOpenConnectionPragmaStatements: String = '');
begin
  FDataBaseName:= aDataBaseName;
  FOpenConnectionFlags := aOpenConnectionFlags;
  FOpenConnectionPragmaStatements := TstringList.Create;
  FOpenConnectionPragmaStatements.Text := trim(AlStringReplace(aOpenConnectionPragmaStatements,';',#13#10,[rfReplaceAll]));
  FConnectionPool:= TObjectList.Create(True);
  FConnectionPoolCS:= TCriticalSection.create;
  FDatabaseRWCS := TMultiReadExclusiveWriteSynchronizer.Create;
  FDatabaseWriteLocked := False;
  FWorkingConnectionCount:= 0;
  FReleasingAllconnections := False;
  FLastConnectionGarbage := ALGettickCount64;
  FConnectionMaxIdleTime := 1200000; // 1000 * 60 * 20 = 20 min
  FNullString := '';
end;


{**********************************************************************}
constructor TalSqlite3ConnectionPoolClient.Create(aDataBaseName: String;
                                                  const aOpenConnectionFlags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
                                                  const aOpenConnectionPragmaStatements: String = '';
                                                  const alib: String = 'sqlite3.dll';
                                                  const initializeLib: Boolean = True);
begin
  fLibrary := TALSqlite3Library.Create;
  try
    fLibrary.Load(alib, False);
    config(SQLITE_CONFIG_MULTITHREAD);
    if initializeLib then initialize;
    FownLibrary := True;
    initObject(aDataBaseName,
               aOpenConnectionFlags,
               aOpenConnectionPragmaStatements);
  Except
    fLibrary.free;
    raise;
  end;
end;

{**********************************************************************}
constructor TalSqlite3ConnectionPoolClient.Create(aDataBaseName: String;
                                                  alib: TALSqlite3Library;
                                                  const aOpenConnectionFlags: integer = SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
                                                  const aOpenConnectionPragmaStatements: String = '');
begin
  fLibrary := alib;
  FownLibrary := False;
  initObject(aDataBaseName,
             aOpenConnectionFlags,
             aOpenConnectionPragmaStatements);
end;

{************************************************}
destructor TalSqlite3ConnectionPoolClient.Destroy;
begin

  //Release all connections
  ReleaseAllConnections;

  //free object
  FOpenConnectionPragmaStatements.free;
  FConnectionPool.free;
  FConnectionPoolCS.free;
  FDatabaseRWCS.Free;
  if FownLibrary then fLibrary.Free;

  //inherite
  inherited;

end;

{***************************************************************}
procedure TalSqlite3ConnectionPoolClient.config(Option: Integer);
begin
  CheckAPIError(nil, FLibrary.sqlite3_config(Option) <> SQLITE_OK);
end;

{**************************************************}
procedure TalSqlite3ConnectionPoolClient.initialize;
begin
  CheckAPIError(nil, FLibrary.sqlite3_initialize <> SQLITE_OK);
end;

{************************************************}
procedure TalSqlite3ConnectionPoolClient.shutdown;
begin
  CheckAPIError(nil, FLibrary.sqlite3_shutdown <> SQLITE_OK);
end;

{****************************************************************************}
procedure TalSqlite3ConnectionPoolClient.enable_shared_cache(enable: boolean);
begin
  if enable then CheckAPIError(nil, FLibrary.sqlite3_enable_shared_cache(1) <> SQLITE_OK)
  else CheckAPIError(nil, FLibrary.sqlite3_enable_shared_cache(0) <> SQLITE_OK);
end;

{*************************************************************************}
function TalSqlite3ConnectionPoolClient.soft_heap_limit64(n: int64): int64;
begin
  result := Flibrary.sqlite3_soft_heap_limit64(n);
end;

{***************************************************************************************************}
function TalSqlite3ConnectionPoolClient.AcquireConnection(const readonly: boolean = False): PSQLite3;
Var aConnectionPoolContainer: TalSqlite3ConnectionPoolContainer;
    aTickCount: int64;
    aDoPragma: Boolean;
Begin

  //init aDoPragma
  aDoPragma := False;

  //synchronize the code
  FConnectionPoolCS.Acquire;
  Try

    //raise an exception if currently realeasing all connection
    if FReleasingAllconnections then raise exception.Create('Can not acquire connection: currently releasing all connections');

    //delete the old unused connection
    aTickCount := ALGetTickCount64;
    if aTickCount - fLastConnectionGarbage > (60000 {every minutes})  then begin
      while FConnectionPool.Count > 0 do begin
        aConnectionPoolContainer := TalSqlite3ConnectionPoolContainer(FConnectionPool[0]);
        if aTickCount - aConnectionPoolContainer.Lastaccessdate > FConnectionMaxIdleTime then begin
          Try
            FLibrary.sqlite3_close(aConnectionPoolContainer.ConnectionHandle);
          Except
            //Disconnect must be a "safe" procedure because it's mostly called in
            //finalization part of the code that it is not protected
            //that the bulsheet of SQLite3 to answer SQLITE_BUSY instead of free
            //everything
          End;
          FConnectionPool.Delete(0); // must be delete here because FConnectionPool free the object also
        end
        else break;
      end;
      FLastConnectionGarbage := aTickCount;      
    end;

    //acquire the new connection from the pool
    If FConnectionPool.Count > 0 then begin
      aConnectionPoolContainer := TalSqlite3ConnectionPoolContainer(FConnectionPool[FConnectionPool.count - 1]);
      Result := aConnectionPoolContainer.ConnectionHandle;
      FConnectionPool.Delete(FConnectionPool.count - 1);
    end

    //create a new connection
    else begin
      Result := nil;
      Try
        CheckAPIError(result, fLibrary.sqlite3_open_v2(PAnsiChar(fDatabaseName), result, FOpenConnectionFlags, nil) <> SQLITE_OK);
        aDoPragma := True;
      Except
        //A database connection handle is usually returned in *ppDb, even if an error occurs.
        //Whether or not an error occurs when it is opened, resources associated with the
        //database connection handle should be released by passing it to sqlite3_close()
        //when it is no longer required
        if assigned(result) then fLibrary.sqlite3_close(result);
        Raise;
      End;
    end;

    //increase the connection count
    inc(FWorkingConnectionCount);

  //get out of the synchronization
  finally
    FConnectionPoolCS.Release;
  end;

  //only one writer at a time OR multi reader at a time
  if ReadOnly then FDatabaseRWCS.BeginRead
  else begin
    FDatabaseRWCS.BeginWrite;
    FDatabaseWriteLocked := True;
  end;

  //execute the pragma here because before we can have an exception database is locked
  try
    if aDoPragma then UpdateData(FOpenConnectionPragmaStatements,result);
  Except

    //synchronize the code
    FConnectionPoolCS.Acquire;
    Try

      //dec the WorkingConnectionCount
      dec(FWorkingConnectionCount);

    //get out of the synchronization
    finally
      FConnectionPoolCS.Release;
    end;

    //release the lock
    if FDatabaseWriteLocked then begin
      FDatabaseWriteLocked := False;
      FDatabaseRWCS.EndWrite;
    end
    else FDatabaseRWCS.EndRead;

    //free the result
    if assigned(result) then fLibrary.sqlite3_close(result);

    //raise the exception
    Raise;

  End;

End;

{***************************************************************************************}
{Applications must finalize all prepared statements and close all BLOB handles associated
 with the sqlite3 object prior to attempting to close the object. If sqlite3_close() is
 called on a database connection that still has outstanding prepared statements or
 BLOB handles, then it returns SQLITE_BUSY.
 If sqlite3_close() is invoked while a transaction is open, the transaction is
 automatically rolled back.}
procedure TalSqlite3ConnectionPoolClient.ReleaseConnection(var ConnectionHandle: PSQLite3;
                                                           const CloseConnection: Boolean = False);
Var aConnectionPoolContainer: TalSqlite3ConnectionPoolContainer;
begin

  //security check
  if not assigned(ConnectionHandle) then raise exception.Create('Connection handle can not be null');

  //release the connection
  FConnectionPoolCS.Acquire;
  Try

    //add the connection to the pool
    If (not CloseConnection) and (not FReleasingAllconnections) then begin
      aConnectionPoolContainer := TalSqlite3ConnectionPoolContainer.Create;
      aConnectionPoolContainer.ConnectionHandle := ConnectionHandle;
      aConnectionPoolContainer.LastAccessDate := ALGetTickCount64;
      FConnectionPool.add(aConnectionPoolContainer);
    end

    //close the connection
    else begin
      try
        FLibrary.sqlite3_close(ConnectionHandle);
      Except
        //Disconnect must be a "safe" procedure because it's mostly called in
        //finalization part of the code that it is not protected
      end;
    end;

    //set the connectionhandle to nil
    ConnectionHandle := nil;

    //dec the WorkingConnectionCount
    Dec(FWorkingConnectionCount);

  finally
    FConnectionPoolCS.Release;
  end;

  //release the lock
  if FDatabaseWriteLocked then begin
    FDatabaseWriteLocked := False;
    FDatabaseRWCS.EndWrite;
  end
  else FDatabaseRWCS.EndRead;

end;

{***********************************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.ReleaseAllConnections(Const WaitWorkingConnections: Boolean = True);
Var aConnectionPoolContainer: TalSqlite3ConnectionPoolContainer;
begin

  {we do this to forbid any new thread to create a new transaction}
  FReleasingAllconnections := True;
  Try

    //wait that all transaction are finished
    if WaitWorkingConnections then
      while true do begin
        FConnectionPoolCS.Acquire;
        Try
          if FWorkingConnectionCount <= 0 then break;
        finally
          FConnectionPoolCS.Release;
        end;
        sleep(1);
      end;

    {free all database}
    FConnectionPoolCS.Acquire;
    Try
      while FConnectionPool.Count > 0 do begin
        aConnectionPoolContainer := TalSqlite3ConnectionPoolContainer(FConnectionPool[FConnectionPool.count - 1]);
        Try
          FLibrary.sqlite3_close(aConnectionPoolContainer.ConnectionHandle);
        Except
          //Disconnect must be a "safe" procedure because it's mostly called in
          //finalization part of the code that it is not protected
        End;
        FConnectionPool.Delete(FConnectionPool.count - 1); // must be delete here because FConnectionPool free the object also
      end;
      FLastConnectionGarbage := ALGetTickCount64;
    finally
      FConnectionPoolCS.Release;
    end;

  finally
    //Do not forbid anymore new thread to create a new transaction
    FReleasingAllconnections := False;
  End;

end;

{***************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.TransactionStart(Var ConnectionHandle: PSQLite3;
                                                          const ReadOnly: boolean = False);
begin

  //ConnectionHandle must be null
  if assigned(ConnectionHandle) then raise exception.Create('Connection handle must be null');

  //init the aConnectionHandle
  ConnectionHandle := AcquireConnection(ReadOnly);
  try

    //start the transaction
    UpdateData('BEGIN TRANSACTION', ConnectionHandle);

  except
    ReleaseConnection(ConnectionHandle, True);
    raise;
  end;

end;

{*****************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.TransactionCommit(var ConnectionHandle: PSQLite3;
                                                           const CloseConnection: Boolean = False);
begin

  //security check
  if not assigned(ConnectionHandle) then raise exception.Create('Connection handle can not be null');

  //commit the transaction
  UpdateData('COMMIT TRANSACTION', ConnectionHandle);

  //release the connection
  ReleaseConnection(ConnectionHandle, CloseConnection);

end;

{******************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.TransactionRollback(var ConnectionHandle: PSQLite3;
                                                             const CloseConnection: Boolean = False);
var aTmpCloseConnection: Boolean;
begin

  //security check
  if not assigned(ConnectionHandle) then raise exception.Create('Connection handle can not be null');

  //rollback the connection
  aTmpCloseConnection := CloseConnection;
  Try
    Try
      UpdateData('ROLLBACK TRANSACTION', ConnectionHandle);
    except
      //to not raise an exception, most of the time TransactionRollback
      //are call inside a try ... except
      //raising the exception here will hide the first exception message
      //it's not a problem to hide the error here because closing the
      //connection will normally rollback the data
      aTmpCloseConnection := True;
    End;
  Finally

    //release the connection
    ReleaseConnection(ConnectionHandle, aTmpCloseConnection);

  End;

end;

{***************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                                                    XMLDATA: TalXMLNode;
                                                    OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                                    ExtData: Pointer;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);

Var astmt: PSQLite3Stmt;
    aStepResult: integer;
    aColumnCount: Integer;
    aColumnIndex: integer;
    aColumnNames: Array of String;
    aNewRec: TalXmlNode;
    aValueRec: TalXmlNode;
    aViewRec: TalXmlNode;
    aSQLsindex: integer;
    aRecIndex: integer;
    aRecAdded: integer;
    aTmpConnectionHandle: PSQLite3;
    aOwnConnection: Boolean;
    aContinue: Boolean;
    aXmlDocument: TalXmlDocument;
    aUpdateRowTagByFieldValue: Boolean;

begin

  //clear the XMLDATA
  if assigned(XMLDATA) then begin
    XMLDATA.ChildNodes.Clear;
    aXmlDocument := Nil;
  end
  else begin
    aXmlDocument := ALCreateEmptyXMLDocument('root');
    XMLDATA := aXmlDocument.DocumentElement;
  end;

  try

    //acquire a connection and start the transaction if necessary
    aTmpConnectionHandle := ConnectionHandle;
    aOwnConnection := (not assigned(ConnectionHandle));
    if aOwnConnection then TransactionStart(aTmpConnectionHandle, True);
    Try

      {loop on all the SQL}
      For aSQLsindex := 0 to length(SQLs) - 1 do begin

        //prepare the query
        astmt := nil;
        CheckAPIError(aTmpConnectionHandle, FLibrary.sqlite3_prepare_v2(aTmpConnectionHandle, Pchar(SQLs[aSQLsindex].SQL), length(SQLs[aSQLsindex].SQL), astmt, nil) <> SQLITE_OK);
        Try

          //Return the number of columns in the result set returned by the
          //prepared statement. This routine returns 0 if pStmt is an SQL statement
          //that does not return data (for example an UPDATE).
          aColumnCount := FLibrary.sqlite3_column_count(astmt);

          //init the aColumnNames array
          setlength(aColumnNames,aColumnCount);
          For aColumnIndex := 0 to aColumnCount - 1 do
            aColumnNames[aColumnIndex] := FLibrary.sqlite3_column_name(astmt, aColumnIndex);

          //init the aViewRec
          if (SQLs[aSQLsindex].ViewTag <> '') and (not assigned(aXmlDocument))  then aViewRec := XMLdata.AddChild(SQLs[aSQLsindex].ViewTag)
          else aViewRec := XMLdata;

          //init aUpdateRowTagByFieldValue
          if AlPos('&>',SQLs[aSQLsindex].RowTag) = 1 then begin
            delete(SQLs[aSQLsindex].RowTag, 1, 2);
            aUpdateRowTagByFieldValue := True;
          end
          else aUpdateRowTagByFieldValue := False;

          //loop throught all row
          aRecIndex := 0;
          aRecAdded := 0;
          while True do begin

            //retrieve the next row
            aStepResult := FLibrary.sqlite3_step(astmt);

            //break if no more row
            if aStepResult = SQLITE_DONE then break

            //download the row
            else if aStepResult = SQLITE_ROW then begin

              //process if > Skip
              inc(aRecIndex);
              If aRecIndex > SQLs[aSQLsindex].Skip then begin

                //stop if no row are requested
                If (SQLs[aSQLsindex].First = 0) then break;

                //init NewRec
                if (SQLs[aSQLsindex].RowTag <> '') and (not assigned(aXmlDocument))  then aNewRec := aViewRec.AddChild(SQLs[aSQLsindex].RowTag)
                Else aNewRec := aViewRec;

                //loop throught all column
                For aColumnIndex := 0 to aColumnCount - 1 do begin
                  aValueRec := aNewRec.AddChild(ALlowercase(aColumnNames[aColumnIndex]));
                  aValueRec.Text := GetFieldValue(astmt,
                                                  aColumnIndex,
                                                  FormatSettings);
                  if aUpdateRowTagByFieldValue and (aValueRec.NodeName=aNewRec.NodeName) then aNewRec.NodeName := ALLowerCase(aValueRec.Text);
                end;

                //handle OnNewRowFunct
                if assigned(OnNewRowFunct) then begin
                  aContinue := True;
                  OnNewRowFunct(aNewRec, SQLs[aSQLsindex].ViewTag, ExtData, aContinue);
                  if Not aContinue then Break;
                end;

                //free the node if aXmlDocument
                if assigned(aXmlDocument) then aXmlDocument.DocumentElement.ChildNodes.Clear;

                //handle the First
                inc(aRecAdded);
                If (SQLs[aSQLsindex].First >= 0) and (aRecAdded >= SQLs[aSQLsindex].First) then Break;

              end;

            end

            //misc error, raise an exception
            else CheckAPIError(aTmpConnectionHandle, True);

          end;

        Finally
          //free the memory used by the API
          CheckAPIError(aTmpConnectionHandle, FLibrary.sqlite3_finalize(astmt) <> SQLITE_OK);
        End;

      end;

      //commit the transaction and release the connection if owned
      if aOwnConnection then TransactionCommit(aTmpConnectionHandle);

    except
      On E: Exception do begin

        //rollback the transaction and release the connection if owned
        if aOwnConnection then TransactionRollback(aTmpConnectionHandle, true);

        //raise the error
        raise;

      end;
    end;

  Finally
    if assigned(aXmlDocument) then aXmlDocument.free;
  End;

end;

{*************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                                                    OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                                    ExtData: Pointer;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0] := Sql;
  SelectData(aSelectDataSQLs,
             nil,
             OnNewRowFunct,
             ExtData,
             FormatSettings,
             ConnectionHandle);
end;

{**************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: String;
                                                    Skip: Integer;
                                                    First: Integer;
                                                    OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                                    ExtData: Pointer;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := '';
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := Skip;
  aSelectDataSQLs[0].First := First;
  SelectData(aSelectDataSQLs,
             nil,
             OnNewRowFunct,
             ExtData,
             FormatSettings,
             ConnectionHandle);
end;

{**************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: String;
                                                    OnNewRowFunct: TalSqlite3ClientSelectDataOnNewRowFunct;
                                                    ExtData: Pointer;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := '';
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := -1;
  aSelectDataSQLs[0].First := -1;
  SelectData(aSelectDataSQLs,
             nil,
             OnNewRowFunct,
             ExtData,
             FormatSettings,
             ConnectionHandle);
end;

{***************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQLs: TalSqlite3ClientSelectDataSQLs;
                                                    XMLDATA: TalXMLNode;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
begin

  SelectData(SQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings,
             ConnectionHandle);

end;

{*************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: TalSqlite3ClientSelectDataSQL;
                                                    XMLDATA: TalXMLNode;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0] := Sql;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings,
             ConnectionHandle);
end;

{**************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: String;
                                                    RowTag: String;
                                                    Skip: Integer;
                                                    First: Integer;
                                                    XMLDATA: TalXMLNode;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := RowTag;
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := Skip;
  aSelectDataSQLs[0].First := First;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings,
             ConnectionHandle);
end;

{**************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: String;
                                                    RowTag: String;
                                                    XMLDATA: TalXMLNode;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := RowTag;
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := -1;
  aSelectDataSQLs[0].First := -1;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings,
             ConnectionHandle);
end;

{**************************************************************}
procedure TalSqlite3ConnectionPoolClient.SelectData(SQL: String;
                                                    XMLDATA: TalXMLNode;
                                                    FormatSettings: TformatSettings;
                                                    const ConnectionHandle: PSQLite3 = nil);
var aSelectDataSQLs: TalSqlite3ClientSelectDataSQLs;
begin
  setlength(aSelectDataSQLs,1);
  aSelectDataSQLs[0].Sql := Sql;
  aSelectDataSQLs[0].RowTag := '';
  aSelectDataSQLs[0].viewTag := '';
  aSelectDataSQLs[0].skip := -1;
  aSelectDataSQLs[0].First := -1;
  SelectData(aSelectDataSQLs,
             XMLDATA,
             nil,
             nil,
             FormatSettings,
             ConnectionHandle);
end;

{***************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.UpdateData(SQLs: TalSqlite3ClientUpdateDataSQLs;
                                                    const ConnectionHandle: PSQLite3 = nil);
Var astmt: PSQLite3Stmt;
    aSQLsindex: integer;
    aTmpConnectionHandle: PSQLite3;
    aOwnConnection: Boolean;
begin

  //exit if no SQL
  if length(SQLs) = 0 then Exit;

  //acquire a connection and start the transaction if necessary
  aTmpConnectionHandle := ConnectionHandle;
  aOwnConnection := (not assigned(ConnectionHandle));
  if aOwnConnection then TransactionStart(aTmpConnectionHandle, False);
  Try

    {loop on all the SQL}
    For aSQLsindex := 0 to length(SQLs) - 1 do begin

      //prepare the query
      CheckAPIError(aTmpConnectionHandle, FLibrary.sqlite3_prepare_v2(aTmpConnectionHandle, Pchar(SQLs[aSQLsindex].SQL), length(SQLs[aSQLsindex].SQL), astmt, nil) <> SQLITE_OK);
      Try

        //retrieve the next row
        CheckAPIError(aTmpConnectionHandle, not (FLibrary.sqlite3_step(astmt) in [SQLITE_DONE, SQLITE_ROW]));

      Finally
        //free the memory used by the API
        CheckAPIError(aTmpConnectionHandle, FLibrary.sqlite3_finalize(astmt) <> SQLITE_OK);
      End;

    end;

    //commit the transaction and release the connection if owned
    if aOwnConnection then TransactionCommit(aTmpConnectionHandle);

  except
    On E: Exception do begin

      //rollback the transaction and release the connection if owned
      if aOwnConnection then TransactionRollback(aTmpConnectionHandle, true);

      //raise the error
      raise;

    end;
  end;

end;

{*************************************************************************************}
procedure TalSqlite3ConnectionPoolClient.UpdateData(SQL: TalSqlite3ClientUpdateDataSQL;
                                                    const ConnectionHandle: PSQLite3 = nil);
Var aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
begin
  setlength(aUpdateDataSQLs,1);
  aUpdateDataSQLs[0] := SQL;
  UpdateData(aUpdateDataSQLs, ConnectionHandle);
end;

{*****************************************************************}
procedure TalSqlite3ConnectionPoolClient.UpdateData(SQLs: Tstrings;
                                                    const ConnectionHandle: PSQLite3 = nil);
Var aSQLsindex : integer;
    aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
begin
  setlength(aUpdateDataSQLs,SQLs.Count);
  For aSQLsindex := 0 to SQLs.Count - 1 do begin
    aUpdateDataSQLs[aSQLsindex].SQL := SQLs[aSQLsindex];
  end;
  UpdateData(aUpdateDataSQLs, ConnectionHandle);
end;

{**************************************************************}
procedure TalSqlite3ConnectionPoolClient.UpdateData(SQL: String;
                                                    const ConnectionHandle: PSQLite3 = nil);
Var aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
begin
  setlength(aUpdateDataSQLs,1);
  aUpdateDataSQLs[0].SQL := SQL;
  UpdateData(aUpdateDataSQLs, ConnectionHandle);
end;

{************************************************************************}
procedure TalSqlite3ConnectionPoolClient.UpdateData(SQLs: array of String;
                                                    const ConnectionHandle: PSQLite3 = nil);
Var aUpdateDataSQLs: TalSqlite3ClientUpdateDataSQLs;
    i: integer;
begin
  setlength(aUpdateDataSQLs,length(SQLs));
  for I := 0 to length(SQLs) - 1 do begin
    aUpdateDataSQLs[i].SQL := SQLs[i];
  end;
  UpdateData(aUpdateDataSQLs, ConnectionHandle);
end;


{***************************************************************}
function TalSqlite3ConnectionPoolClient.ConnectionCount: Integer;
begin
  FConnectionPoolCS.Acquire;
  Try
    Result := FConnectionPool.Count + FWorkingConnectionCount;
  finally
    FConnectionPoolCS.Release;
  end;
end;

{**********************************************************************}
function TalSqlite3ConnectionPoolClient.WorkingConnectionCount: Integer;
begin
  FConnectionPoolCS.Acquire;
  Try
    Result := FWorkingConnectionCount;
  finally
    FConnectionPoolCS.Release;
  end;
end;

end.
