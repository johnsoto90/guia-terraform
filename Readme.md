## Instalación

Para instalar terraform en windows lo puedes descargar directamente desde la pagina oficial de terraform o puedes usar el comando de chocolatey para instalarlo.

```cmd
  choco install terraform
```

Si vas a usar terraform con AWS necesitas instalar el CLI de AWS y configurarlo con tus credenciales, puedes bajar el instalador desde la pagina oficial de AWS o puedes usar el comando de chocolatey para instalarlo.

```cmd
  choco install awscli
```

Luego de instalarlo deberas configurar las credenciales de tu cuenta de AWS, se recomienda crear un usuario con AMI con los permisos necesarios para crear los recursos que necesites.

```cmd
  aws configure
```

## Comandos principales

```cmd
  terraform init
```

Se usa para inicializar el directorio de trabajo, descargando los plugins necesarios para el proveedor que se va a usar.

```cmd
  terraform plan
```

Su funcion es generar un plan de ejecución, este plan se puede guardar en un archivo para ser usado posteriormente.

```cmd
  terraform apply
```

Usado para aplicar el plan de ejecución, este comando puede ser usado con el plan generado anteriormente o con el plan generado por el comando plan.

```cmd
  terraform destroy
```

Como el nombre indica, este comando es usado para destruir los recursos creados por terraform.

Los demas comandos los puedes ver en la documentación oficial de terraform. [Documentación oficial](https://www.terraform.io/docs/commands/index.html)

## Ejemplo de uso

En este ejemplo se creara una instancia EC2 en AWS con la configuracion minima usando terraform.

Creamos un archivo llamado main.tf con el siguiente contenido.

##### main.tf

```hcl
terraform {
  required_providers {
    # Se especifica la version del proveedor en este caso AWS
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    # Se especifica la region donde se creara la instancia
  region = "us-east-1"
}
# Instruccion para crear una instancia EC2 en AWS
resource "aws_instance" "example" {
  ami           = "ami-007855ac798b5175e" # Imagen Ubuntu LTS
  instance_type = "t2.micro" # Tipo de instancia
}

```

Luego de crear el archivo ejecutamos el comando init para inicializar el directorio de trabajo.

```cmd
  terraform init
```

Seguido de esto ejecutamos el comando plan para generar el plan de ejecución.

```cmd
  terraform plan
```

El cual tendra el siguiente output:

```cmd
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                                  = "ami-007855ac798b5175e"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags_all                             = (known after apply)
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
Despues de generar el plan de ejecución ejecutamos el comando apply para crear la instancia EC2.

```cmd
  terraform apply
```
En este caso el output sera el siguiente:

```cmd
aws_instance.example: Creating...
aws_instance.example: Still creating... [10s elapsed]
aws_instance.example: Still creating... [20s elapsed]
aws_instance.example: Still creating... [30s elapsed]
aws_instance.example: Creation complete after 34s [id=i-0b9c1c9c9c9c9c9c9]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
