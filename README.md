#scp-backuper  
  
-----  

 scp-backuperはscpを使って、指定したディレクトリをサーバにコピーするためのスクリプトです。ディレクトリツリーの通りにコピーされ、2回目からは更新されたもののみをコピーします。公開鍵方式を使うことを前提としているので、自動実行させることができます。  
  

###使い方  
まず`scp_backuper.sh`の5, 6, 7行目のところで`scp_backuper.conf`と`.latest_backup_date`, `known_dir`を置くパスを好きなところに書き換えます。(書き換えなくてもいい。)
`.latest_backup_date`と`known_dir`は初回実行時に、指定したパスに生成されます。
`scp_backuper`は実行するとまず`scp_backuper.conf`を見に行き、実行に必要な情報を得ます。その後scpコマンドを実行し、最後に`.latest_backup_date`と`known_dir`を作ります。2回目からは`.latest_backup_date`より更新日時が新しい物のみコピーします。  
`scp_backuper.conf`はscpコマンドに必要な情報等を持ちます。  
`known_dir`はバックアップ対象のディレクトリと、そこに含まれるサブディレクトリのパスを持ちます。バックアップ元のディレクトリに新しいサブディレクトリが作られたかどうかを確認するためです。

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
これで終わりですが、rootでscpやsshをしたことがないと初回実行時にrootの`~/.ssh/known_hosts`にサーバが載っていないのでリストに加えるか聞かれます。なので終了やrebootする前に、一度接続してリストに加える必要があります。

