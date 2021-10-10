#Importante

 - Este repositorio es un archivo .tf que trabaja con terraform para levantar una WebApp con una base de datos MySQL mediante un Auto Scaling Group y Load Balancer

 - Antes de arrancar con el terraform hay que ir a AWS Secret Manager y crear un nuevo secret.

 - El secret se debe de llamar rtb-db-secret y debe contener 4 keys indispensables: username, password, host y db para que la WebApp se conecte a la base de datos.

 - Las keys se hacen referencia a los siguiente:

      ```
      'mysql://{username}:{password}@{host}/{db}'.format(
          **get_secret('rtb-db-secret')
      )
      ```

 - El value de las keys si quieres cambiarlos son:
      ```
      Secret Key               |     Secret Value
                               |
      username                 |     Aquí se indica el username del resource "aws_db_instance"
      password                 |     Aquí se indica el password del resource "aws_db_instance"
      engine                   |     Aquí se indica el engine del resource "aws_db_instance"
      host                     |     Aquí se indica el endpoint del database (RDS) creado dentro de la interfaz de AWS
      db                       |     Aquí se indica name del resource "aws_db_instance"
      port                     |     Aquí se indica el puerto de la base de datos MySQL que por defecto es 3306
      dbInstanceIdentifier     |     Aquí se indica el identifier del resource "aws_db_instance"
      ```

      · Los values del resource "aws_db_instance" tienen que coincidir con los Secret value

 - Este repositorio es o ha sido una práctica que va a ser comprobada por un profesor utilizando mi cuenta de aws por lo que este paso ya lo tengo hecho para que funcione.

#Instrucciones

 - Lo primero sera instalar terraform si no lo tienes instalado --> https://www.terraform.io/downloads.html

 - Una vez instalado terraform se deberá hacer un terraform init para instalar el directorio de trabajo para otros comandos.

 - Ahora solo hay que hacer un terraform apply y en unos segundos te pedirá confirmar con un "yes", si quieres comprobar que todo está bien hecho lo puedes hacer con un terraform plan antes que el apply y te indicará si hay algo mal o algún fallo.

 - La instalación de todos los recursos tardará unos minutos (8-10 minutos).

#Notas

 - Si no se cambian los nombres de los resource todos los nombres empezarán por un "tf-" para difereciar con nombres similares

 - En principio no tiene que haber ningún problema para la instalación pero si por algún casual aparece algún un error con las 2 claves que adjunto, clave_ssh_terraform y clave_ssh_terraform.pub, se puede entrar a la instancia por medio de un ssh e ir comprobando donde está el/los fallos.

 - Para entrar a la isntancia creada por medio de ssh hay que poner:
     ```
     $ ssh -i clave_ssh_terraform ec2-user@IP-ADDRESS
     ```
     · Sustituir IP-ADDRESS por la ip de la instancia

 - Si se quiere cambiar las claves que yo he dejado por otras se pueden crear poniendo:
     ```
     ssh-keygen -t rsa
     ```
     · Después de poner este comando te pedirá que elijas la ubicación donde quieras guardar las claves, tanto la privada como la pública (".pub").
