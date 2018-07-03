# BookMark

## 概要

Graphvizを使用してリンク集のグラフを生成するPowerShellスクリプトです。
ブラウザ間で可搬かつ見ためが悪くないお気に入りの生成ツールとして作り初めました。

元々がお気に入り管理用なのでデータソースとなるファイル、出力先のファイルは同一である意識で出発しています。
また、欲しいのは画像ですがそこはGraphviz任せです。本プログラムの主目的はデータCSVからDOT言語のコードを生成することにあります。

## 使い方

設定ファイルとデータCSVを作成の上、build.ps1を起動してください。

### オプション

Paramで指定しているので、読める片はbuild.ps1を読むことを勧めます。

#### Config

設定ファイルへのパスを指定します。省略時は".\config.json"です。

#### InPath

データCSVファイルへのパスを指定します。省略時は".\favorite.csv"です。

#### OutPath

出力結果の保存先ファイルです。設定ファイルのout_pathより優先されます。どちらも存在しないときは標準のストリームへ文字列を出力します。

#### OutFormat

出力形式です。"dot"、"svg"、"png"のいずれかが指定可能です。
省略時は"svg"です。

### データCSV

お気に入りの情報を保存するCSVファイルです。ツリー構造の記述を意図しています。
実際の記述例とその結果出力されるグラフは出力例をご覧ください。

### id列

ノードの識別子です。重複した場合の動作は保証しません。
アルファベットで構成されてることを想定しています。そうでない場合は…今は特に何もしません。

### parent列

親となるノードのidを指定します。

### type列

現在、folederとleafのみ指定可能です。それ以外の場合、そのノードは無視されます。
子要素を持つ場合はfolderにしましょう。

### label列

ノード内に表示する文字列です。\\nを書くことで改行も可能です。
この文字列が長くなるとノードの大きさも横長になるでしょう。

### url

リンク先です。

## 設定ファイル

UTF8エンコードされているjson形式で記述してください。

### encoding

データCSVのエンコード形式です。"SJIS"または"UTF8"のどちらかを指定可能です。
SJISにしておくと、CSVファイルがExcelで編集でき便利です。

### base_directory

中間ファイルの出力先を指定します。

### dot_path

GraphVizのdot実行形式のパスです。dotでなくtwopi等を指定すればそれを用いてレイアウトします。
dotよりtwopi、circoあたりが使いやすいと感じています。
OutFormatオプションで"dot"以外を指定した時は必須です。

## 出力例

データCSV：

<pre>
id,parent,type,label,url
root,,folder,root,
google,root,leaf,google,https://google.com/
w3c,root,leaf,W3C,https://www.w3.org/
bitbucket,root,leaf,bitbucket,https://bitbucket.org/product
</pre>


設定ファイル：
```
{
    "encoding" : "UTF8",
    "base_directory": "C:\\Users\\SomeUser\\Documents\\BookMark",
    "dot_path": "C:\\Program Files (x86)\\Graphviz2.38\\bin\\twopi.exe",
    "out_path": "C:\\Users\\SomeUser\\Documents\\BookMark\\sample.svg"
}
```

[出力ファイル](sample.svg)

