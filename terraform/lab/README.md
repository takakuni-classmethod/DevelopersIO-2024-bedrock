# ラボ環境の立ち上げ方法

HashiCorp Terraform をインストールし、以下のコマンドを実行してラボ環境の立ち上げを行ってください。

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

```bash
git clone https://github.com/takakuni-classmethod/DevelopersIO-2024-bedrock.git
cd /DevelopersIO-2024-bedrock/terraform/lab

terraform init
terraform apply --auto-approve
```

ラボ環境の削除は SageMaker Studio Space を停止したのちに行ってください。

[Studio を実行しているインスタンス、アプリケーション、スペースを削除または停止します。](https://docs.aws.amazon.com/ja_jp/sagemaker/latest/dg/studio-updated-running.html)

```bash
terraform destroy --auto-approve
```
