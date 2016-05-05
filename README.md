#scp-backuper  
  
-----  

 scp-backuperはscpを使って、指定したディレクトリをサーバにコピーするためのスクリプトです。ディレクトリツリーの通りにコピーされ、2回目からは更新されたもののみをコピーします。公開鍵方式を使うことを前提としているので、自動実行させることができます。  
  
  
  

###使い方  
まず`scp_backuper.sh`の4, 5行目のところを`scp_backuper.conf`と`.scp_backuper`を置くパスに書き換えます。
`.scp_backuper`は初回実行時に、指定したパスに生成されます。
`scp_backuper`は実行するとまず`scp_backuper.conf`を見に行き、実行に必要な情報を得ます。その後scpコマンドを実行し、最後に`.scp_backuper`ファイルを書き換えます。2回目からは`.scp_backuper`より更新日時が新しい物のみコピーします。

次に`scp_backuper.conf`を環境に合わせて書き換えます。
`scp_backuper.conf`の設定に関するすべての行は項目名と設定値の間にスペースをひとつ入れます。行間や項目の順番に制約はありません。
*       `User`はscpでアクセスするサーバ上のユーザ名です。
*       `Ip`はscpで接続するサーバのIPアドレスです。
*       `Port`はサーバのscpに対応するポート番号です。
*       `Key`はscpで使う鍵までのパスです。クライアント側(`scp_backuper.sh`を実行する)の鍵です。
*       `BackupDir`はコピー先の(サーバの)ディレクトリです。
*       `BackupTarget`はコピー元のディレクトリです。

あとは実行するだけです。
  
  
  

###システムの終了時に自動実行させる例
Debian8での例です。

設定等は上の"使い方"と同じです。

`scp_backuper.sh`を`/etc/init.d/scp_backuper.sh`にコピーし、所有者をrootに、パーミッションを755にします。
`insserv -d scp_backuper.sh`を実行します。
これで終わりですが、rootでscpやsshをしたことがないと初回実行時にrootの`known_hosts`にサーバが載っていないのでリストに加えるか聞かれます。なので終了やrebootする前に接続してリストに加える必要があります。

