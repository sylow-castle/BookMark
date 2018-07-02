Param($Config = ".\config.json", $InPath = ".\favorite.csv", $OutPath)

#各種設定を確認
function Check-Configration($Conf) {
    $executable = $True;
    $executable = $executable -and $(Test-Path -Path $Conf.base_directory);
    $executable = $executable -and $(Test-Path -Path $Conf.dot_path);
    $executable = $executable -and $Conf.encoding -in ("UTF8", "SJIS");

    $executable;
}


#各種関数
function FolderDot([Parameter(ValueFromPipeline=$true)] $line) {
 process {
  $id = $line.id
  $label = $line.label
  $url = $line.url
  [String]::Format('{0} [label="{1}", shape="ellipse", href="{2}"];', $id, $label, $url);
  }
}

function LeafDot([Parameter(ValueFromPipeline=$true)] $line) {
  process {
  $id = $line.id
  $label = $line.label
  $url = $line.url
  [String]::Format('{0} [label="{1}", href="{2}"];', $id, $label, $url);
  }
}

function Dotize-FromLine([Parameter(ValueFromPipeline=$true)] $line) {
 process {
  switch($line.type) {
    "folder" {$line | FolderDot }
    "leaf" {$line | LeafDot }
  }
  }
}

function Build-Graph($src, [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding] $encode) {
    Get-Content -Encoding $encode $src | 
    ConvertFrom-Csv | 
    % {
        #Nodeを出力
        $_ | Dotize-FromLine | % { @{type="node";dot=$_} };

        #Edgeを出力
        $_ | Where-Object -Property "parent" -Value "" -NE |
        % { $_.parent + " -> " + $_.id + ";"} |
        % { @{type="edge";dot=$_} };
    }
}

function Expand-Template([Parameter(ValueFromPipeline=$true)]$dot_line, $src) {
  begin {$graph = @{node=@();edge=@()}}

  process {$graph[$_.type] += $_.dot}

  end {
    Get-Content -Encoding UTF8 $src | 
      ForEach-Object {
        $_;
        if($_ -like "*NodeList*") {
          $graph.node;
        }

        if($_ -like "*EdgeList*") {
          $graph.edge;
        }
      }
  }
}
#############################################################

if( ! $(Test-Path -Path $Config)) {
    Write-Host "アプリケーション設定ファイルが存在しません。";
    exit 1;
}

Get-Content -Encoding UTF8 $Config | ConvertFrom-Json | sv conf;
if( ! $(Check-Configration $Conf)) {
    $Conf;
    Write-Host "設定に誤りがあったため起動を中止しました"
    exit 1;  
}

$EncodingMap = @{
    "SJIS" = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Default;
    "UTF8" = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::UTF8;
}

<#
$OutPathあり、out_pathあり→$OutPathを採用
$OutPathあり、out_pathなし→$OutPathを採用
$OutPathなし、out_pathあり→out_pathを採用
$OutPathなし、out_pathなし→標準出力（デフォルト）
#>
$StdOut = "";
$out = $StdOut;
if($OutPath -is [string]) {
    $out = $OutPath;
} elseif( $Conf.out_path -ne $null) {
    $out = $Conf.out_path;
}

try {
    $src = Get-Item -ErrorAction Stop -Path $InPath;
} catch [Exception] {
    $error
    exit 1
}


#中間ファイルの前処理
$targetFile = ".\source.txt";
$target = Get-Item $targetFile;
"" | Out-File -FilePath $target.PSPath -Encoding utf8;

$template = Get-Item ".\template.txt";




Build-Graph -src $src -encode $EncodingMap[$Conf.encoding] |
    Expand-Template -src $template |
    Out-File -FilePath $target.PSPath -Append -Encoding utf8;

if($out -eq $StdOut) {
    &$conf.dot_path -Tsvg $targetFile
} else {
    &$conf.dot_path -Tsvg $targetFile -o $out
}



