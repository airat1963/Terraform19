создали новый скрипт user_data1.sh
который копирует сразу всю папку с файлами на созданный с помощью терраформ
в скрипте main.tf бакетом  : TARGET_DIR="s3://otus-bucket-b1g77g5lrul51pldt28m/"

также в файле main.tf   поменял название скрипта на ноый  user_data1.sh
запустили терраформ
получили прокси вм и спарк кластер с 3 мя нодами заданных в дз характеристик ( дата нода с диском размер 120 ГБ)


зашли на прокси вм
ssh ubuntu@адрес вм

Проверка настроек s3cmd
access_key = ***
secret_key = ***
host_base = storage.yandexcloud.net
host_bucket = %(bucket)s.storage.yandexcloud.net
use_https = True

копирование выполнил отдельно, поскольку через скрипт очень долго и вылетает с ошибками ( долгое ожидание отклика)

SOURCE_DIR="s3://otus-mlops-source-data/"
TARGET_DIR="s3://otus-bucket-b1g77g5lrul51pldt28m/"

s3cmd cp \
    --config=/home/ubuntu/.s3cfg \
    --acl-public \
    --recursive \
    "$SOURCE_DIR" \
    "$TARGET_DIR" | tee -a /home/ubuntu/user_data_execution.log


переходим на мастер ноду

ssh dataproc-master

запускаем скрипт bash upload_data_to_hdfs.sh

смотрим результат копирования

ubuntu@rc1a-dataproc-m-l4pt8hvd0bnpfgh6:~$ hdfs dfs -ls /user/ubuntu/data/
Found 7 items
-rw-r--r--   1 ubuntu hadoop 2684354560 2025-03-02 10:58 /user/ubuntu/data/.distcp.tmp.attempt_local1603927491_0001_m_000000_0.1740913105605
-rw-r--r--   1 ubuntu hadoop 2995176166 2025-03-02 10:58 /user/ubuntu/data/2020-03-19.txt
-rw-r--r--   1 ubuntu hadoop 2995810010 2025-03-02 10:54 /user/ubuntu/data/2020-07-17.txt
-rw-r--r--   1 ubuntu hadoop 2994761624 2025-03-02 10:57 /user/ubuntu/data/2020-12-14.txt
-rw-r--r--   1 ubuntu hadoop 2995446495 2025-03-02 10:56 /user/ubuntu/data/2021-04-13.txt
-rw-r--r--   1 ubuntu hadoop 3042358698 2025-03-02 10:56 /user/ubuntu/data/2021-11-09.txt
-rw-r--r--   1 ubuntu hadoop 3042312191 2025-03-02 10:55 /user/ubuntu/data/2022-03-09.txt
…
[Sun 02 Mar 2025 11:22:39 AM UTC] ---------------------------------------------------------- 
[Sun 02 Mar 2025 11:22:39 AM UTC] [INFO] Data was successfully copied to HDFS
ubuntu@rc1a-dataproc-m-l4pt8hvd0bnpfgh6:~$ 

сохранили картинку из хадупа
![Снимок экрана 2025-03-02 hadoop](https://github.com/user-attachments/assets/0f26078f-487d-4917-a47d-680ca8652900)



готовим GitHub для сохранения scripts
https://github.com/airat1963/Terraform19.git

скопировали на master branch

для демонстрации скопированных файлов 
сохранили их ранее в отдельном бакете 
Object Storage
/
Бакеты
/
otus-mlops-data17




























___________________________________________________________________________________________________________________________________
# OTUS. Настройка облачной инфраструктуры

## План занятия

1. Создадим инфраструктуру в Yandex.Cloud с помощью Terraform 
   1. Сервисный аккаунт
   2. Сеть
   3. Объектное хранилище S3
   4. Dataproc кластер
   5. ВМ для доступа к кластеру
 
2. Посмотрим на автоматическую загрузку данных в S3
3. Зайдем на мастерноду Dataproc и загрузим данные в HDFS

## Команды

Команды для работы с Terraform упакованы в Makefile:

```bash
make tf_init
make tf_apply
make tf_destroy
```

## Структура проекта

```
.
├── README.md                       # Документация проекта
├── Makefile                        # Команды для управления инфраструктурой
├── check.sh                        # Скрипт для проверки
└── infrastructure/                 # Директория с Terraform конфигурацией
    ├── main.tf                     # Основной файл с описанием ресурсов
    ├── variables.tf                # Определения переменных
    ├── outputs.tf                  # Выходные значения
    ├── provider.tf                 # Настройки провайдера
    ├── terraform.tfvars.example    # Пример файла с переменными
    └── scripts/                    # Скрипты для настройки инфраструктуры
        ├── user_data.sh            # Скрипт инициализации ВМ
        └── upload_data_to_hdfs.sh  # Скрипт загрузки данных в HDFS
```

## Предварительные требования

1. Установленный [Terraform](https://developer.hashicorp.com/terraform/downloads)
2. Аккаунт в [Yandex Cloud](https://cloud.yandex.ru/)
3. Настроенный [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart)
4. SSH ключи для доступа к создаваемым ВМ

## Настройка

1. Скопируйте файл с примером переменных:
```bash
cp infrastructure/terraform.tfvars.example infrastructure/terraform.tfvars
```

2. Заполните переменные в файле `terraform.tfvars`:
- `yc_token` - OAuth токен
- `yc_cloud_id` - ID облака
- `yc_folder_id` - ID каталога
- `yc_image_id` - ID образа Ubuntu 20.04
- `public_key_path` - путь к публичному SSH ключу
- `private_key_path` - путь к приватному SSH ключу

## Развертывание инфраструктуры

1. Инициализация Terraform:
```bash
make tf_init
```

2. Применение конфигурации:
```bash
make tf_apply
```

После успешного применения конфигурации, в выводе будут показаны:
- IP адрес прокси-ВМ
- Имя созданного S3 бакета

## Подключение к кластеру

1. Подключитесь к прокси-ВМ:
```bash
ssh ubuntu@<proxy_public_ip>
```

2. С прокси-ВМ можно подключиться к мастер-ноде Dataproc:
```bash
ssh dataproc-master
```

## Удаление инфраструктуры

Для удаления всех созданных ресурсов выполните:
```bash
make tf_destroy
```

## Дополнительная информация

- [Документация Yandex Cloud](https://cloud.yandex.ru/docs)
- [Документация Terraform](https://developer.hashicorp.com/terraform/docs)
- [Документация Dataproc](https://cloud.yandex.ru/docs/data-proc)

## Лицензия

MIT

## Автор

- [Nick Osipov](https://t.me/NickOsipov)
