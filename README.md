# Terraform Infra
## _Manifest for VMware Cloud Director_
[![Terraform](https://hashicorp.gallerycdn.vsassets.io/extensions/hashicorp/terraform/2.20.0/1646144695729/Microsoft.VisualStudio.Services.Icons.Default)](https://www.terraform.io/)

## Применение:
*   Создаёт/изменяет VM в заданной конфигурации:
    * OS из vApp Templates;   
    * CPU/RAM;
    * Один или множество сетевых интерфейсов;
    * Один или множество дополнительных дисков (с учётом Storage Profile);
    * LVM-разметку на дополнительных дисках.

## Состав:
Конфигурационные файлы самого манифеста:
* Изменяемые:

| Файл | Описание |
| ------ | ------ |
| [datacenters.tf][PlG_DC] | Содержит data-сущности виртуальных ДЦ VCD-окружения; |
| [os.tf][PlG_OS] | Локальная переменная со вложенным словарём. В качетсве ключей указываются  алиасы  с названием ОС и её версии. В качестве значения вложенного словаря - реальное название vApp Template на который ссылаются алиасы; |
| [catalogs.tf][PlG_CATALOGS] | Содержит data-сущность директории, где хранятся vApp Templates и локальную переменную `templates`, ссылающуюся на неё;  |
| [networks.tf][PlG_NETWORKS] | Содержит data-сущности всех routed-сетей и локальную переменную `net` со словарями, где в качестве значений используются ссылки на них, а в качестве ключей - алиасы; |
| [storages.tf][PlG_STORAGES] | Содержит data-сущности всех storage для создания дисков, подключаемых к VM; |
| [disks.tf][PlG_DISKS] | Содержит локальные переменные со словарями, где в качестве значений используются ссылки на storage, подключаемых к VM, а в качестве ключей - алиасы; |
| [VMs.tf][PlG_VM_DP] | Содержит локальную переменную со словарями внутри. Каждый словарь описывает полную конфигурацию создаваемой VM - от её имени до разметки LVM-разделов;  |
| [terraform.tfvars][PlG_VARS_TF] | Содержит значения системных переменных - от URL-адреса ДЦ до указания учётных данных для авторизации в VCD;  |
| [storage-bucket.tf][PlG_BUCKET] | Содержит блок конфигурации для хранения удалённого state-файла в S3-хранилище.  |

[PlG_DC]: <https://github.com/noirgt/terrainfra_vcd/blob/main/datacenters.tf>
[PlG_OS]: <https://github.com/noirgt/terrainfra_vcd/blob/main/os.tf>
[PlG_CATALOGS]: <https://github.com/noirgt/terrainfra_vcd/blob/main/catalogs.tf>
[PlG_NETWORKS]: <https://github.com/noirgt/terrainfra_vcd/blob/main/catalogs.tf>
[PlG_STORAGES]: <https://github.com/noirgt/terrainfra_vcd/blob/main/storages.tf>
[PlG_DISKS]: <https://github.com/noirgt/terrainfra_vcd/blob/main/disks.tf>
[PlG_VM_DP]: <https://github.com/noirgt/terrainfra_vcd/blob/main/VMs-DP.tf>
[PlG_VM_AVNTG]: <https://github.com/noirgt/terrainfra_vcd/blob/main/VMs-AVNTG.tf>
[PlG_VARS_TF]: <https://github.com/noirgt/terrainfra_vcd/blob/main/terraform.tfvars.example>
[PlG_BUCKET]: <https://github.com/noirgt/terrainfra_vcd/blob/main/storage-bucket.tf.example>

* Неизменяемые:

| Файл | Описание |
| ------ | ------ |
| [variables.tf][PlG_VARS] | Содержит набор необходимых переменных определяемых в конфигурации манифеста; |
| [modules/*][PlG_MODULES] | Содержит набор модулей для создания и пост-конфигурации VM: _копирование ключей для SSH-авторизации_, _изменение дефолтного шлюза_, _создание LVM-разделов_. |

[PlG_VARS]: <https://github.com/noirgt/terrainfra_vcd/blob/main/variables.tf>
[PlG_MODULES]: <https://github.com/noirgt/terrainfra_vcd/blob/main/modules>

> Под значением "алиас" подразумевается короткий ключ словаря для вызова длинного пути data-сущности в качестве его значения.

## Начало работы:
1) Подготовить необходимые vApp Templates для разворачивания VM из шаблонов. 
В рамках шаблона необходимо заранее создать сервисного пользователя 
со стандартным паролем - это необходимо для подключения к VM через Ansible 
на этапе пост-конфигурации. Для выполнения операций Ansible, 
требующих повышенного уровня прав, необходимо добавить создаваемому пользователю 
привилегии `sudo`.
2) Отредактировать **изменяемые** `.tf`-файлы и привести data-сущности 
и содержимое локальных переменных в соответствие с содержимым 
вашей VCD-инфраструктуры;
3) Cкопировать содержимое файла `storage-bucket.tf.example` в `storage-bucket.tf` в корне проекта и определить следующие переменные:
    * `endpoint` - S3 endpoint;
    * `bucket` - название S3 bucket;
    * `region` - регион S3;
    * `key` - путь до state-файла в S3;
    * `s3_access_key` - сервисный access-ключ для хранения state в S3;
    * `s3_secret_key` - сервисный secret-ключ для хранения state в S3.
4) Скопировать содержимое файла `terraform.tfvars.example` в `terraform.tfvars` в корне проекта и определить следующие переменные:
    * `vcd_user` - имя пользователя для доступа к VCD;
    * `vcd_pass` - пароль для доступа к VCD;
    * `vcd_org` - название организации VCD;
    * `vcd_vdc` - название Дата Центра VCD;
    * `vcd_url` - URL-адрес VCD;
    * `vcd_max_retry_timeout` - максимальное количество времени (в секундах), в течение которого вы готовы ожидать успешного взаимодействия с ресурсами (по умолчанию задано - 60 секунд);
    * `vcd_allow_unverified_ssl` - логическое значение, для которого можно установить значение true, чтобы отключить проверку сертификата SSL (по умолчанию задано - false, то есть сертификат проверяется);
    * `ssh_user` - имя сервисного пользователя для подключения к VM по SSH (добавляется на этапе создания шаблона);
    * `ssh_pass` - пароль сервисного пользователя для подключения к созданной VM по SSH;
    * `public_ssh_key_path` - локальный путь к публичному ключу SSH для доступа к созданной VM без пароля.
4) Выполнить инициализацию манифеста и подключаемых модулей в корне директории:
```
terraform init
```
## Примеры конфигурации VM:
> Конфигурация для создания VM указывается в файле `VMs.tf`;
> Блок конфигурации VM в необходимо разместить в качестве 
> вложенного словаря в структуре: 
```hcl
locals {
    vms  = {}
}
```
К примеру, требуется создать несколько VM:
```hcl
locals {
vms  = {  
# Start space for configuration

"vm3-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {2:4}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}" : "10.101.5.90"},
    2: {"${local.net["test"]}" : "10.101.3.94"},
    }
}

"vm4-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {1:1}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}": "10.101.5.104"}
    },
    "vm_disks"      : {
    1: {"${local.disk_dp["ssd"]}": "1G"},
    2: {"${local.disk_dp["hdd"]}": "2G"}
    },
    "lvm"           : {
    1: "/opt",
    2: "/mnt"
    }
}

# End space for configuration
}
}
```
Первый блок конфигурации добавит VM с именем `vm3-terra` 
и следующими характеристиками:
*   OS - Ubuntu 20.04;
*   CPU - 2 ядра;
*   RAM - 4G;
*   Network:
    * Интерфейс #1 (сервисная сеть) - IP 10.101.5.90;
    * Интерфейс #2 (тестовая сеть) - IP 10.101.3.94.
    
Второй блок конфигурации добавит VM с именем `vm4-terra` 
и следующими характеристиками:
*   OS - Ubuntu 20.04;
*   CPU - 1 ядро;
*   RAM - 1Gb;
*   Network:
    * Интерфейс #1 (сервисная сеть) - IP 10.101.5.104.
*   Дополнительные диски:
    * SSD-диск #1 - объёмом 1G (с LVM и точкой монтирования "/opt");
    * HDD-диск #2 - объёмом 2G (с LVM и точкой монтирования "/mnt");

Если необходимо добавить ещё одну или несколько VM, 
достаточно расширить содержимое файла с конфигурацией VM ещё одним блоком:
```hcl
locals {
vms  = {  
# Start space for configuration

"vm3-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {2:4}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}" : "10.101.5.90"},
    2: {"${local.net["test"]}" : "10.101.3.94"},
    }
}

"vm4-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {1:1}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}": "10.101.5.104"}
    },
    "vm_disks"      : {
    1: {"${local.disk_dp["ssd"]}": "1G"},
    2: {"${local.disk_dp["hdd"]}": "2G"}
    },
    "lvm"           : {
    1: "/opt",
    2: "/mnt"
    }
}

"vm5-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {1:2}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["prod"]}": "10.101.0.110"}
    },
    "vm_disks"      : {
    1: {"${local.disk_dp["ssd"]}": "100G"}
    },
    "lvm"           : {
    1: "/var/lib/docker"
    }
}

# End space for configuration
}
}
```
Если, к примеру, спустя время требуется расширить объём LVM-раздела созданной 
ранее VM при помощи Terraform, достаточно сделать следующее:
```hcl
"vm4-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {1:1}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}": "10.101.5.104"}
    },
    "vm_disks"      : {
    1: {"${local.disk_dp["ssd"]}": "1G"},
    2: {"${local.disk_dp["hdd"]}": "2G"},
    3: {"${local.disk_dp["hdd"]}": "10G"}
    },
    "lvm"           : {
    1: "/opt",
    2: "/mnt",
    3: "/opt"
    }
}
```
В вышеуказанном примере мы добавляем ещё один диск для 
созданной ранее VM `vm4-terra` объёмом **10G** и расширяем раздел, 
примонтированный в `/opt`. Теперь общий объём 
расширенного Logical Volume будет составлять **11G**, вместо прежнего **1G**.
