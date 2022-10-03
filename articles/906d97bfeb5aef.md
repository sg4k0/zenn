---
title: "Zenn CLI環境をRemote Containersを利用して構築"
emoji: "🐥"
type: "tech"
topics: ["vscode", "devcontainer", "zenn"]
published: true
---

Zennの記事の投稿を行うにあたって、継続的に投稿できる環境を作成したいと思い、かつPCが破損しても再構築が簡単な状態で残したいため、Docker(devcontainer)を利用したZennCLI環境を構築しました。
Zenn自体に似たような記事が多数あり、正直そちらを利用でも良いと思ったのですが、利用しないときはコンテナ削除したいタイプで、コンテナ削除してもすぐ起動できるようにライブラリはDocker Image内入れてしまいたかったので新たに作成しました。
前提としてGithubと連携して投稿します。

## Dockerfile作成〜devcontainer作成

### Dockerfile作成

まずはディレクトリを作成します。
私は`zenn`というディレクトリを作成しました。
作成したディレクトリに`Dockerfile`を作成します。
```docker:Dockerfile
FROM node:alpine

RUN apk --no-cache add git \
 && yarn global add zenn-cli
USER node
WORKDIR /home/node/zenn
```

`zenn-cli`はグローバルにインストールしています。
`node_modules`をホスト側で管理したくなかったのと、わざわざpackage.jsonで管理するまでもない環境なのでグローバルにインストールしました。
また、これらをDocker Image内に入れておけば、コンテナを削除したとしても次起動したときはライブラリがインストールされた状態からなので起動も早いです。

### devcontainer作成

続いて`.devcontainer`ディレクトリを作成します。
これはVSCodeのRemote Containerで参照されるディレクトリです。
この中にRemote Containerの設定ファイル`.devcontainer.json`を作成します。

```json:.devcontainer.json
{
  "name": "Zenn CLI",
  "context": "..",
  "dockerFile": "../Dockerfile",
  "mounts": [ 
    "source=${localEnv:HOME}${localEnv:USERPROFILE}/zenn,target=/home/node/zenn,type=bind",
    "source=${localEnv:HOME}${localEnv:USERPROFILE}/.gitconfig,target=/home/node/.gitconfig,type=bind"
  ],
  "extensions": [
    "negokaz.zenn-editor"
  ]
}
```

`mounts`の項目の1行目でホスト側とRemote Containerのファイルを共有できるようにします。
この記載がない場合、コンテナを消したときにせっかく作成したファイルとおさらばすることになります。
2行目はホスト側で設定したgitの設定を共有しています。
今回利用しているnode.jsのベースイメージはユーザーがnodeとなるため、コンテナ側の`/home/node/`においています。
また、`extensions`で拡張機能`Zenn Editor`を指定しています。これで、起動時に拡張機能がインストールされます。

各ファイルは以下の構成となります。

```
zenn
├─ .devcontainer
│ └── devcontainer.json
└─ Dockerfile
```

## Remote Container起動〜記事作成

### Remote Container起動

ここまで来たらあとはVSCodeのRemote Containerを起動します。
左下の緑色><マークをクリックすると選択肢のリストが開くので、「Open Folder in Container...」をクリックしてください。
今回作成した`zenn`ディレクトリを選択すると新たなVSCodeが起動し、DockerのBuildや拡張機能のダウンロードなどを行ってくれます。
新しく起動したVSCodeはコンテナに接続しているので、ここからの作業はコンテナ上での作業となります。

### 記事作成

`zenn-cli`の初期化を行います。

```sh
zenn init
```

上記のコマンドを実施すると、各ディレクトリとファイルが作成されます。

- articles
- books
- .gitignore
- README.md

新たな記事を作成する場合は以下のコマンドを実施します。

```sh
zenn new:article
```

`articles/ランダムなslug.md`というファイルが作成されます。

これ以降は以下を参照してください。

https://zenn.dev/zenn/articles/zenn-cli-guide

注意点は今回グローバルにライブラリを入れているため、Zenn公式の記事に記載されているコマンドの`npx`などが不要となります。

Githubとの連携は以下を参照してください。

https://zenn.dev/zenn/articles/connect-to-github

## 最後に

手軽さで行くとRemote Containerでnodeを指定して起動したコンテナを利用して、ライブラリなどを入れていく方が楽だと思います。
ただ、コンテナが削除されたらまた一から実施する必要があり、コンテナの良さがあまり生かされないなと感じました。
そのため、今回ライブラリなどをDocker Imageに含めてしまった環境を構築しました。
すきあらば`docker container prune`してしまう私にはこれが一番適していました。
拡張機能やライブラリはLintツールなどを入れても良いと思います。私も今後充実させて行きたいと考えています。
なお、今回alpineイメージを利用しましたがその他でもいいと思います。
どなたかのお役に立てば幸いです。
