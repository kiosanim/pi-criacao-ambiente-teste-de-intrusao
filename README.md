# Criação de um LAB para Testes de Intrusão

* **Autor:** Fábio Sartori (p41m31)
* **E-mail:** p41m31@protonmail.com
* **Copyright:** 20220312


  Para este ambiente de **TESTES** em caráter educacional,
a nuvem a ser utilizada é a Linode.

  **NÃO INCENTIVAMOS** o uso de qualquer ferramenta aqui instalada em
qualquer ambiente sem **PRÉVIA AUTORIZAÇÃO**


  A estação de trabalho considerada nesta documentação, para a instalação dos
**PRÉ-REQUISITOS** é um Linux baseado em Ubuntu 20.04.
  Mas as URL's para as documentações oficiais serão disponibilizadas, com isto
será possível verificar o processo de instalação em outros sistemas operacionais.

   
---

## Informações gerais

| Arquivo | Descrição |
|---------|-----------|
| README.md | Este Arquivo|
| .gitignore | Lista com os arquivos que não serão versionados pelo git |
| IaC/terraform/criar_linodes.tf | Script Terraform para criação das máquinas virtuais |
| IaC/terraform/terraform.auto.tfvars.sample | Template do arquivo de propriedades do Terraform |
| IaC/ansible/ansible.cfg | Configurações gerais do Ansible |
| IaC/ansible/playbook.yml | Playbook para configuração das máquinas virtuais |
| IaC/ansible/hosts.sample | Template com a lista com os IPs das máquinas virtuais |
| IaC/ansible/pi/usuarios.txt | Dicionário com nomes comuns de usuários para o Brute-Force Attack |
| IaC/ansible/pi/senhas.txt | Dicionário com as senhas para o Brute-Force Attack |
| IaC/ansible/pi/registro.sh | Shell Script para registrar os resultados |


---

## Criação de uma conta na nuvem Linode

* [https://linode.com](https://linode.com)
* [Como criar uma conta no Linode](https://www.linode.com/docs/guides/getting-started/)

  Será necessário também, a criação de um **ACCESS TOKEN**, com permissão de escrita para a
criação de Linodes (como são chamadas as VM's na plataforma)

* [Como criar um ACCESS TOKEN](https://www.linode.com/docs/products/tools/linode-api/guides/get-access-token/)

---


# Instalação dos pré-requisitos na estação de trabalho


A estação de trabalho é uma distro Linux baseada no Ubuntu.

## Instalando o X2Go Client

[Documentação e instaladores do X2Go Client](https://wiki.x2go.org/doku.php/download:start)


```bash
sudo apt-get update && sudo apt-get install x2goclient

```

## Instalando o sshpass (Cliente ssh não-interativo) - Somente Windoes

```bash
sudo apt-get update && sudo apt-get install sshpass

```

## Instalação das ferramentas IaC (Infrastructure As Code)

### Instalação do Terraform

[Documentação do Terraform](https://www.terraform.io/docs)

```bash
sudo apt-get update && sudo apt-get install terraform
```

### Instalação do Ansible

[Documentação do Ansible](https://docs.ansible.com/)

```bash
sudo apt-get update && sudo apt-get install ansible ansible-doc ansible-lint
```

---

# Criação das máquinas virtuais


Entre no diretório **Iac/terraform**

```bash
cd Iac/terraform
```


  Crie um arquivo **IaC/terraform/terraform.auto.tfvars** a partir do
**IaC/terraform/linodes/terraform.auto.tfvars.sample** e
preencha as propriedades conforme abaixo:

| Prefixo da Propriedade | Descrição |
|------------------------|-----------|
| kali_ | Propriedade específica do servidor kali_pi |
| centos_ | Propriedade específica do servidor centos_pi |
| shared_ | Variável válida para os dois tipos de servidores |


| Propriedade | Descrição | Exemplo |
|-------------|-----------|---------|
| shared_token | Access Token do Linode | alkdjflkasdjfladad... |
| shared_root_pass | Senha do usuário root nos servidores em texto plano | qawsedrf |
| shared_region | Região de datacenter do Linode | us-central |
| shared_private_ip | Se os servidores terão IP's privados (rede interna) | true |
| kali_tags | Array com tags para organização | ["api", "webserver", "etc"] |
| kali_label | Label do servidor na console de administração do Linode | servidor_web | 
| kali_image | Imagem base para a criação da Máquina Virtual | linode/ubuntu20.04 |
| kali_type | Tipo do servidor (Tamanho / Configuração de Hardware Virtual) | g6-standard-4|
| centos_tags | Array com tags para organização | ["api", "webserver", "etc"] |
| centos_label| Label do servidor na console de administração do Linode | servidor_web | 
| centos_image | Imagem base para a criação da Máquina Virtual | linode/centos7 |
| centos_type | Tipo do servidor (Tamanho / Configuração de Hardware Virtual) | g6-standard-1 |


As máquinas virtuais serão criadas com a ferramenta **Terraform**


## Instalar o Provider Terraform do Linode

```bash
terraform init
```


## Valide o script para criação das máquinas virtuais

```bash
terraform validate
```


## Valide o plano de execução do script

```bash
terraform plan
```

## Crie as máquinas virtuais

```bash
terraform apply
```
Digite **yes** para confirmar


## Verifique os IPs dos servidores:

O comando abaixo irá listar todas as informações do(s) servidor(es) criado(s)

```bash
terraform show

```

Entre os dados retornados, haverão três que identificam as máquinas.
São eles:

* **label:** Label da máquina no Linode
* **ip_address:** IP Público da máquina virtual
* **private_ip_address:** IP da rede privada da máquina virtual


---


# Configuração das máquinas virtuais com o Ansible.


Entre no diretório **Iac/ansible**

```bash
cd Iac/terraform
```

## Senhas dos usuários

### Gerar o hash da senha dos usuários

Será solicitada a uma senha para gerar o hash que será adicionado ao script de configuração


```bash
 mkpasswd --method=sha-512
 Senha: 
$6$fWZMjX4iwStW$Yyxc...

```


### Adicionar a senha gerada pelo passo anterior, no playbook.yml na sessão de criação do usuário azureuser

Edite o arquivo **playbook.yml** e na task **Criar o usuário...**, adicione o hash gerado no parâmetro **password**

No exemplo: Usuário xpto

```bash
.
.
.
tasks:
    - name: Criar o usuário xpto
      user:
        name: xpto
        password: "$6$fWZMjX4iwStW$Yyxc..."
.
.
.
```
---


## IPs dos Servidores

Faça uma cópia do arquivo **IaC/ansible/hosts.sample** com o nome **IaC/ansible/hosts**
Preencha os IPs públicos dos servidores no arquivo **IaC/ansible/hosts**

Para ilustrar, utilizarei **IPs Inválidos e Fictícios** apenas para demonstrar onde irão.

* **kali_pi:** 999.999.999.999
* **centos_pi:** 111.111.111.111


```text
[kali_pi]
999.999.999.999

[centos_pi]
111.111.111.111

```

## Validando a sintaxe do playbook.yml


```bash
ansible-playbook  playbook.yml  --syntax-check
```

## Executando o playbook.yml


```bash
ansible-playbook -i hosts playbook.yml -u root -k
```
