{
vet'OS calcul de ration
-----------------------
Jabouley Florent 2020
}


unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Class, LR_DSet, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Spin, Grids, ComCtrls, BCButton, ZConnection,
  fpsTypes, Zdataset, Dateutils, DB;

type

  { TForm1 }

  TForm1 = class(TForm)
    BCButton1: TBCButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    calc: TLabeledEdit;
    cell: TLabeledEdit;
    chatactivite: TComboBox;
    chatpathologie: TComboBox;
    chatphysiologie: TComboBox;
    chatrace: TComboBox;
    CheckBox2: TCheckBox;
    chienactivite: TComboBox;
    chienpathologie: TComboBox;
    chienphysiologie: TComboBox;
    chienrace: TComboBox;
    chienrpc: TComboBox;
    dash: TLabeledEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    fabricant: TRadioButton;
    FloatSpinEdit1: TFloatSpinEdit;
    hum: TLabeledEdit;
    Image2: TImage;
    inscriptions: TRadioButton;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    matg: TLabeledEdit;
    PageControl1: TPageControl;
    panelchat2: TPanel;
    panelchat3: TPanel;
    panel_aliment: TPanel;
    panel_chat: TPanel;
    panel_chien: TPanel;
    frReport1: TfrReport;
    Label1: TLabel;
    Label5: TLabel;
    Accueil: TTabSheet;
    clientanimal: TTabSheet;
    alimliste: TTabSheet;
    calculsresultats: TTabSheet;
    phosph: TLabeledEdit;
    prot: TLabeledEdit;
    radiochat: TRadioButton;
    radiochien: TRadioButton;
    sgrecherche: TStringGrid;
    Zconnect1: TZConnection;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    //    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure chatphysiologieClick(Sender: TObject);
    //    procedure CheckBox1Change(Sender: TObject);
    procedure chienphysiologieChange(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frReport1GetValue(const ParName: string; var ParValue: variant);
    procedure frUserDataset1First(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure protChange(Sender: TObject);
    procedure radiochienChange(Sender: TObject);
    procedure RadioGroup1ChangeBounds(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure sCellEdit1Change(Sender: TObject);
    procedure sgrechercheDblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

type
  typerecherche = (sclient, sanimal);

type
  espece_animal = (chien, chat);

type
  recherches = set of typerecherche;

type
  aliment = packed record
    nom: string;
    Source: string;
    indications: string;
    recommandations: string;
    reference: string;
    pourcentage_ration: double;
    energie,
    proteines,
    cellulose,
    matieres_grasses,
    cendres,
    humidite,
    ena,
    calcium,
    phosphore: double;
  end;

type
  aliments = array of aliment;

type
  race = packed record
    nom: string;
    facteur: double;
  end;

type
  races = array of race;

type
  activite = packed record
    nom: string;
    facteur: double;
  end;

type
  activites = array of activite;


var
  ena, de, me, poids, proteines, cellulose, mg, cendres, humidite, ge, edigest: double;
  st: array [1..255] of string;

var
  rpc, pclegume, pcmg, pcfeculent, pcviande: double;

var
  qviande, qlegume, qmg, qfeculent: double;

var
  eviande, elegume, emg, efeculent: double;

var
  pds: double;

var
  be: double;

var
  s1, s2, s3, s4: TStringList;

var
  v1, v2, v3, v4: TStringList;

const
  val_clinique = 'Calcul de ration';

procedure connect_db;

// helper pour conversion date SQlite (origine string)
type
  TFieldHelper = class Helper for Tfield
    function AsSQLiteDate: tdatetime;
  end;

implementation

{$R *.lfm}

{ TForm1 }



procedure LoadClientInfos(id: string);
var
  jquery: TZquery;
begin
  jquery := TZquery.Create(nil);
  try
    connect_db;
    with jquery do
    begin
      Connection := Form1.Zconnect1;
      SQL.Clear;
      SQL.Add('SELECT * FROM CLIENTS');
      SQL.Add('WHERE ID=:ID_CLIENT');
      ParamByName('ID_CLIENT').AsString := id;
      Open;
      if not EOF then
      begin

      end;
      Close;
      Connection.Disconnect;
    end;
  finally
    jquery.Free;
  end;
end;


function TFieldHelper.AsSQLiteDate: tdatetime;
var
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DateSeparator := '-';
  FS.ShortDateFormat := 'yyyy-mm-dd';
  FS.ShortTimeFormat := 'hh:mm:ss.zzz';
  Result := StrToDateTime((self.AsString), FS);
end;

type
  ages = (fa_year, fa_month, fa_day);

type
  set_ages = set of ages;

function format_age(d: tdatetime; f_ages: set_ages = [fa_year, fa_month]): string;
var
  i: integer;
begin
  Result := '';

  if fa_year in f_ages then
  begin
    i := YearsBetween(now, d);
    case i of
      0: Result := Result + '';
      1: Result := Result + IntToStr(i) + ' an ';
      else
        Result := Result + IntToStr(i) + ' ans ';
    end;
  end;
  if fa_month in f_ages then
  begin
    i := monthsbetween(now, d) mod 12;
    case i of
      0: Result := Result + '';
      else
        Result := Result + IntToStr(i) + ' mois ';
    end;
  end;

  if fa_day in f_ages then
  begin
    i := daysbetween(now, d) mod 365;
    case i of
      0: Result := Result + '';
      1: Result := Result + IntToStr(i) + ' jour ';
      else
        Result := Result + IntToStr(i) + ' jours ';
    end;
  end;

end;

procedure Recherche(nclient, nanimal: string; ntype: recherches; var sg: TstringGrid);
var
  jquery: TZquery;
var
  i: integer;
var
  d: TdateTime;
var
  naiss: string;
begin

  sg.RowCount := 1;
  jquery := TZquery.Create(nil);
  try
    connect_db;
    with jquery do
    begin
      Connection := Form1.Zconnect1;
      SQL.Clear;
      // Recherche hors index
      SQL.Add('SELECT A.ID AS IDCLIENT,B.ID AS IDANIMAL, A.NOM AS NOMC, B.NOM AS NOMA, B.NAISSANCE AS NAISS,');
      SQL.Add('B.ESPECE, B.RACE, B.SEXE');
      SQL.Add('FROM CLIENTS A, ANIMAUX B');
      SQL.Add('WHERE (UPPER(A.NOM) LIKE :NCLIENT) AND (UPPER(B.NOM) LIKE :NANIMAL)');
      SQL.Add('AND (A.ID=B.ID_CLIENT)');
      ParamByName('NCLIENT').AsString := uppercase('%' + nclient + '%');
      ParamByName('NANIMAL').AsString := uppercase('%' + nanimal + '%');
      Open;

      while not EOF do
      begin
        i := sg.Rowcount;
        sg.RowCount := i + 1;

        // récupération données
        sg.cells[0, i] := FieldByName('IDCLIENT').AsString;
        sg.cells[1, i] := FieldByName('IDANIMAL').AsString;
        sg.cells[2, i] := FieldByName('NOMC').AsString;
        sg.cells[3, i] := FieldByName('NOMA').AsString;
        sg.cells[4, i] := FieldByName('ESPECE').AsString;
        sg.cells[5, i] := FieldByName('RACE').AsString;

        // conversion age
        naiss := 'inconnu';
        if FieldByName('NAISS').AsString <> '' then
        begin
          d := FieldByName('NAISS').AsSQLiteDate;
          naiss := format_age(d, [fa_year, fa_month, fa_day]);
        end;
        sg.cells[6, i] := naiss;

        Next;
      end;
      Close;
      Connection.Disconnect;
    end;

  finally
    jquery.Free;
  end;

end;



function Calcul_Besoins_Energetiques(esp: espece_animal; poids: double;
  krace, kactivite, kpatho, kphysio: integer): double;
var
  be: double;
var
  k1, k2, k3, k4: double;
begin

  case esp of
    chat:
    begin
      case krace of
        0: k1 := 1.5;
        1: k1 := 1;
      end;

      case kactivite of
        0: k2 := 0.8;
        1: k2 := 0.9;
        2: k2 := 1;
      end;

      case kpatho of
        0: k3 := 0.8;
        1: k3 := 0.6;
        2: k3 := 1.5;
        3: k3 := 1;
      end;
      case kphysio of
        0: k4 := 70;
        1: k4 := 60;
        2: k4 := 100;
        3: k4 := 200;
        4: k4 := 250;
        5: k4 := 130;
        6: k4 := 100;
        7: k4 := 80;
        8: k4 := 200;
        9: k4 := 105;
        10: k4 := 80;
        11: k4 := 65;
      end;
      be := k1 * k2 * k3 * k4 * poids;
    end;
    chien:
    begin
      case krace of
        0: k1 := 0.8;
        1: k1 := 0.9;
        2: k1 := 1.1;
        3: k1 := 1;
      end;
      case kactivite of
        0: k2 := 0.8;
        1: k2 := 1;
        2: k2 := 1.2;
      end;
      case kpatho of
        0: k3 := 1;
        1: k3 := 0.8;
        2: k3 := 0.6;
        3: k3 := 0.8;
        4: k3 := 1.2;
      end;
      case kphysio of
        0: k4 := 1;
        1: k4 := 0.8;
        2: k4 := 1.3;
        3: k4 := 2.5;
        4: k4 := 2;
        5: k4 := 1.7;
        6: k4 := 1.2;
      end;
      if poids <= 10 then
      begin
        be := k1 * k2 * k3 * k4 * 130 * exp(0.75 * ln(poids));
      end;
      if poids > 10 then
      begin
        be := k1 * k2 * k3 * k4 * 156 * exp(0.67 * ln(poids));
      end;
    end;

  end;
  Result := be;
end;


procedure clearst(var arst: array of string);
var
  i: integer;
begin
  for i := 1 to length(arst) - 1 do
    arst[i] := '';
end;

function cvpv(texte: string): string;
var
  i: integer;
begin
  for i := 1 to length(texte) - 1 do
    if texte[i] = '.' then
      texte[i] := ',';
  Result := texte;
end;



function getbe(poids: double): double;
var
  be: double;
begin
  with form1 do
  begin
    //Calcul ration chat
    clearst(st);
    st[7] := formatfloat('0.0', poids);
    if radiochat.Checked then
    begin
      st[1] := 'chat';
      case chatrace.ItemIndex of
        0: k1 := 1.5;
        1: k1 := 1;

      end;
      case chatactivite.ItemIndex of
        0: k2 := 0.8;
        1: k2 := 0.9;
        2: k2 := 1;
      end;
      case chatpathologie.ItemIndex of
        0: k3 := 0.8;
        1: k3 := 0.6;
        2: k3 := 1.5;
        3: k3 := 1;
      end;
      case chatphysiologie.ItemIndex of
        0: k4 := 70;
        1: k4 := 60;
        2: k4 := 100;
        3: k4 := 200;
        4: k4 := 250;
        5: k4 := 130;
        6: k4 := 100;
        7: k4 := 80;
        8: k4 := 200;
        9: k4 := 105;
        10: k4 := 80;
        11: k4 := 65;
      end;
      st[8] := 'Race (k1): ' + chatrace.Text + #13 + 'Activité (k2): ' +
        chatactivite.Text + #13 + 'Pathologies (k3): ' + chatpathologie.Text + #13 +
        'Physiologie (k4): ' + chatphysiologie.Text;
      be := k1 * k2 * k3 * k4 * poids;
      st[6] := 'Méthode de calcul du BE : P x K';
    end
    else
    begin
      // calcul de ration pour chien
      st[1] := 'chien';
      case chienrace.ItemIndex of
        0: k1 := 0.8;
        1: k1 := 0.9;
        2: k1 := 1.1;
        3: k1 := 1;
      end;
      case chienactivite.ItemIndex of
        0: k2 := 0.8;
        1: k2 := 1;
        2: k2 := 1.2;
      end;
      case chienpathologie.ItemIndex of
        0: k3 := 1;
        1: k3 := 0.8;
        2: k3 := 0.6;
        3: k3 := 0.8;
        4: k3 := 1.2;
      end;
      case chienphysiologie.ItemIndex of
        0: k4 := 1;
        1: k4 := 0.8;
        2: k4 := 1.3;
        3: k4 := 2.5;
        4: k4 := 2;
        5: k4 := 1.7;
        6: k4 := 1.2;
      end;
      st[8] := 'Race (k1): ' + chienrace.Text + #13 + 'Activité (k2): ' +
        chienactivite.Text + #13 + 'Pathologies (k3): ' + chienpathologie.Text + #13 +
        'Physiologie (k4): ' + chienphysiologie.Text;
      if poids <= 10 then
      begin
        st[6] := 'Méthode de calcul du BE : 130xP^(0,75)xK';
        be := k1 * k2 * k3 * k4 * 130 * exp(0.75 * ln(poids));
      end;
      if poids > 10 then
      begin
        st[6] := 'Méthode de calcul du BE : 156xP^(0,67)xK';
        be := k1 * k2 * k3 * k4 * 156 * exp(0.67 * ln(poids));
      end;
    end;
    st[1] := 'Pour le ' + st[1] + ' ' + form1.labelededit2.Text + ' de Mr ou Mme ' +
      form1.labelededit1.Text;
    st[2] := formatfloat('0.0', k1);
    st[3] := formatfloat('0.0', k2);
    st[4] := formatfloat('0.0', k3);
    st[5] := formatfloat('0.0', k4);

    st[10] := 'Besoin énergétique calculé : ' + formatfloat('0.0', be) + ' kcal/jour';
    Result := be;

  end;
end;


procedure connect_db;
begin
  with form1.Zconnect1 do
  begin
    Database := extractfilepath(ParamStr(0)) + 'dbration.db';
    LibraryLocation := extractfilepath(ParamStr(0)) + 'sqlite3.dll';
    Connect;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  jquery: TZquery;
begin
  connect_db;
  jquery := TZquery.Create(nil);
  try

    with jquery do
    begin
      Connection := Zconnect1;
      SQL.Clear;
      SQL.Add('SELECT * FROM CLIENTS');
      Open;
      if not EOF then
        ShowMessage(FieldByName('NOM').AsString);
      Connection.Disconnect;
    end;

  finally
    jquery.Free;
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  frreport1.LoadFromFile('ration.lrf');
  frreport1.ShowReport;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  recherche(edit3.Text, edit4.Text, [], sgrecherche);
end;

procedure TForm1.chatphysiologieClick(Sender: TObject);
begin

end;

procedure TForm1.chienphysiologieChange(Sender: TObject);
begin

end;

procedure TForm1.Edit3Change(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.frReport1GetValue(const ParName: string; var ParValue: variant);
begin
  if ParName = 'st1' then
    ParValue := st[1];
  if ParName = 'st2' then
    ParValue := st[2];
  if ParName = 'st3' then
    ParValue := st[3];
  if ParName = 'st4' then
    ParValue := st[4];
  if ParName = 'st5' then
    ParValue := st[5];
  if ParName = 'st6' then
    ParValue := st[6];
  if ParName = 'st7' then
    ParValue := st[7];
  if ParName = 'st8' then
    ParValue := st[8];
  if ParName = 'st9' then
    ParValue := st[9];
  if ParName = 'st10' then
    ParValue := st[10];
  if ParName = 'st11' then
    ParValue := st[11];
  if ParName = 'st12' then
    ParValue := val_clinique;
end;

procedure TForm1.frUserDataset1First(Sender: TObject);
begin
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin

end;

procedure TForm1.protChange(Sender: TObject);
begin

end;

procedure TForm1.radiochienChange(Sender: TObject);
begin
  if radiochien.Checked then
  begin
    ;
    panel_chien.Visible := True;
    panel_chat.Visible := False;
  end;
  if radiochat.Checked then
  begin
    ;
    panel_chien.Visible := False;
    panel_chat.Visible := True;
  end;
end;

procedure TForm1.RadioGroup1ChangeBounds(Sender: TObject);
begin

end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin

end;

procedure TForm1.sCellEdit1Change(Sender: TObject);
begin

end;

procedure TForm1.sgrechercheDblClick(Sender: TObject);
var
  y: integer;
begin

  y := (Sender as TStringgrid).selection.Top;
  if y = 0 then
    exit;

end;

end.
