# HBChallenge

Este proyecto es un challenge con una POC de prueba que consiste en la creación de presupuestos y consume recursos de una API, en esta app se aplica una arquitectura MVVM y se utiliza como lenguaje principal Swift y dos Wrappers escritos en Objective-c como también diferentes frameworks como son:

    - AFNetworking: Framework encargado para la capa de red.
    - FMDB: Framework encargado de interactuar con la base de datos local.
    - ObjectMapper: Framework encargado de mapear los objetos recibidos del servicio y transformarlo en un objeto entendible en nuestro lenguaje, en este caso,Swift.
    - DropDown: Framework encargado de mostrar un desplegable customizado.


# Instalación

Para la instalación de este proyecto es necesario tener instalado Xcode, favorablemente XCcode en su versión 12.4 y tener instalado el gestor de dependencias Carthage (https://github.com/Carthage/Carthage). Después de tener el IDE y el gestor de dependencias puedes proceder a ejecutar un clonado del proyecto para mas adelante ejecutarlo y compilarlo.

Una vez cumplas estos requisitos, puedes proceder a instalar los frameworks que anteriormente hemos explicado, ejecutando en tu terminal y en la raíz del proyecto: carthage update --use-xcframeworks .

Posteriormente ya podrás compilar y ejecutar el proyecto.

