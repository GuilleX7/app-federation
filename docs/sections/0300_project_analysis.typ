#import "../utils/string.typ": id

= Análisis y diseño de requisitos <project-analysis>

En este capítulo analizaremos los objetivos del proyecto para elicitar los requisitos. Primero, analizaremos cuáles serán los perfiles de usuario (actores) y definiremos sus necesidades a través de metas. Después, se elicitarán los requisitos necesarios para satisfacer estas necesidades, comenzando por requisitos generales de alto nivel hasta finalizar con requisitos específicos y detallados sobre cómo debe funcionar el software.

== Actores <actors>

En esta sección describimos los actores lógicos que intervienen en los casos de uso. Una persona puede representar más de un actor.

#let twoColumnTable(..rows) = [
  #show table.cell.where(x: 0): set text(weight: "bold")
  #table(columns: 2, ..rows)
]

#let actorIdCounter = counter("actor")
#let actorIdParams = (prefix: "A-", length: 2)

#actorIdCounter.step()
#let hostAppDeveloperActorId = context id(actorIdCounter.at(<hostAppDeveloperActor>).at(0), ..actorIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    hostAppDeveloperActorId,
    [Nombre],
    [Desarrollador de la aplicación anfitriona],
    [Meta],
    [Integra la biblioteca en una aplicación anfitriona, selecciona las aplicaciones remotas y controla dónde y cuándo se cargan y cómo se gestiona su ciclo de vida.],
  ),
  caption: [Actor #hostAppDeveloperActorId],
) <hostAppDeveloperActor>

#actorIdCounter.step()
#let remoteAppDeveloperActorId = context id(actorIdCounter.at(<remoteAppDeveloperActor>).at(0), ..actorIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    remoteAppDeveloperActorId,
    [Nombre],
    [Desarrollador de una aplicación remota],
    [Meta],
    [Proporciona una aplicación para su integración, declara las entradas que ofrece, define la interfaz con la que se comunica y la publica para que la aplicación anfitriona pueda cargarla.],
  ),
  caption: [Actor #remoteAppDeveloperActorId],
) <remoteAppDeveloperActor>

#actorIdCounter.step()
#let endUserActorId = context id(actorIdCounter.at(<endUserActor>).at(0), ..actorIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    endUserActorId,
    [Nombre],
    [Usuario de la aplicación compuesta],
    [Meta],
    [Utiliza la interfaz resultante de integrar la aplicación anfitriona y las aplicaciones remotas.],
  ),
  caption: [Actor #endUserActorId],
) <endUserActor>

#actorIdCounter.step()
#let remoteServerActorId = context id(actorIdCounter.at(<remoteServerActor>).at(0), ..actorIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    remoteServerActorId,
    [Nombre],
    [Servidor de aplicaciones remotas],
    [Meta],
    [Publica la aplicación remota y suministra los recursos que necesita la aplicación anfitriona para integrarla a través de la red.],
  ),
  caption: [Actor #remoteServerActorId],
) <remoteServerActor>

#actorIdCounter.step()
#let browserActorId = context id(actorIdCounter.at(<browserActor>).at(0), ..actorIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    browserActorId,
    [Nombre],
    [Navegador],
    [Meta],
    [Ejecuta la aplicación anfitriona y las aplicaciones integradas, y proporciona el entorno web compartido donde interactúan.],
  ),
  caption: [Actor #browserActorId],
) <browserActor>

== Requisitos generales <general-requirements>

Las siguientes tablas elicitan los objetivos y capacidades requeridos para una solución que integra microfrontends desarrollados y publicados de forma independiente.

#let generalRequirementIdCounter = counter("generalRequirement")
#let generalRequirementIdParams = (prefix: "GR-", length: 2)

#generalRequirementIdCounter.step()
#let remoteCompositionGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<remoteCompositionGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    remoteCompositionGeneralRequirementId,
    [Título],
    [Composición de aplicaciones remotas],
    [Descripción],
    [La solución debe permitir que una aplicación anfitriona cargue y componga aplicaciones frontend desarrolladas y publicadas de forma independiente.],
  ),
  caption: [Requisito general #remoteCompositionGeneralRequirementId],
) <remoteCompositionGeneralRequirement>

#generalRequirementIdCounter.step()
#let programmaticLoadingGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<programmaticLoadingGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    programmaticLoadingGeneralRequirementId,
    [Título],
    [Carga programática],
    [Descripción],
    [La aplicación anfitriona debe poder cargar en tiempo de ejecución una aplicación remota conociendo su ubicación y seleccionando el punto de entrada.],
  ),
  caption: [Requisito general #programmaticLoadingGeneralRequirementId],
) <programmaticLoadingGeneralRequirement>

#generalRequirementIdCounter.step()
#let lifecycleControlGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<lifecycleControlGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    lifecycleControlGeneralRequirementId,
    [Título],
    [Control del ciclo de vida],
    [Descripción],
    [Cada aplicación remota debe ofrecer operaciones para iniciar su interfaz en un contenedor de la aplicación anfitriona y finalizarla posteriormente.],
  ),
  caption: [Requisito general #lifecycleControlGeneralRequirementId],
) <lifecycleControlGeneralRequirement>

#generalRequirementIdCounter.step()
#let independentBuildGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<independentBuildGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    independentBuildGeneralRequirementId,
    [Título],
    [Compilación independiente],
    [Descripción],
    [La aplicación remota debe poder construirse y publicarse por separado de la aplicación anfitriona mediante herramientas de compilación compatibles.],
  ),
  caption: [Requisito general #independentBuildGeneralRequirementId],
) <independentBuildGeneralRequirement>

#generalRequirementIdCounter.step()
#let styleInjectionGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<styleInjectionGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    styleInjectionGeneralRequirementId,
    [Título],
    [Inyección y aislamiento de estilos],
    [Descripción],
    [La solución debe ofrecer interfaces genéricas para inyectar y gestionar el alcance de los estilos, evitando la interferencia con otras aplicaciones del entorno.],
  ),
  caption: [Requisito general #styleInjectionGeneralRequirementId],
) <styleInjectionGeneralRequirement>

#generalRequirementIdCounter.step()
#let communicationGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<communicationGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    communicationGeneralRequirementId,
    [Título],
    [Comunicación entre microfrontends],
    [Descripción],
    [La solución debe ofrecer interfaces genéricas para facilitar el intercambio de datos, acciones o eventos entre aplicaciones cuando sea necesario.],
  ),
  caption: [Requisito general #communicationGeneralRequirementId],
) <communicationGeneralRequirement>


#generalRequirementIdCounter.step()
#let standaloneGeneralRequirementId = context id(
  generalRequirementIdCounter.at(<standaloneGeneralRequirement>).at(0),
  ..generalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    standaloneGeneralRequirementId,
    [Título],
    [Ejecución autónoma],
    [Descripción],
    [Una aplicación remota podrá ejecutarse de forma independiente cuando el proyecto lo requiera, además de integrarse en una aplicación anfitriona.],
  ),
  caption: [Requisito general #standaloneGeneralRequirementId],
) <standaloneGeneralRequirement>

== Requisitos de arquitectura <architectural-requirements>

#let architecturalRequirementIdCounter = counter("architecturalRequirement")
#let architecturalRequirementIdParams = (prefix: "AR-", length: 2)

#architecturalRequirementIdCounter.step()
#let modularPackageArchitectureId = context id(
  architecturalRequirementIdCounter.at(<modularPackageArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    modularPackageArchitectureId,
    [Título],
    [Separación de responsabilidades],
    [Descripción],
    [La solución debe organizarse en módulos con límites claros: uno para la carga e integración de aplicaciones, otro para acceder a la funcionalidad disponible dentro de las aplicaciones remotas, y otro para la creación de aplicaciones remotas.],
  ),
  caption: [Requisito de arquitectura #modularPackageArchitectureId],
) <modularPackageArchitecture>

#architecturalRequirementIdCounter.step()
#let buildToolIntegrationId = context id(
  architecturalRequirementIdCounter.at(<buildToolIntegration>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    buildToolIntegrationId,
    [Título],
    [Integración con herramientas de compilación],
    [Descripción],
    [La solución debe ofrecer una integración con las herramientas de compilación elegidas que permita declarar las entradas remotas y producir los recursos necesarios para que la aplicación anfitriona las descubra y cargue.],
  ),
  caption: [Requisito de arquitectura #buildToolIntegrationId],
) <buildToolIntegration>

#architecturalRequirementIdCounter.step()
#let remoteEntryLoadingArchitectureId = context id(
  architecturalRequirementIdCounter.at(<remoteEntryLoadingArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    remoteEntryLoadingArchitectureId,
    [Título],
    [Carga remota coordinada],
    [Descripción],
    [El mecanismo de carga debe identificar cada aplicación por su ubicación en la red, reutilizar el resultado de peticiones ya realizadas y coordinar solicitudes concurrentes.],
  ),
  caption: [Requisito de arquitectura #remoteEntryLoadingArchitectureId],
) <remoteEntryLoadingArchitecture>

#architecturalRequirementIdCounter.step()
#let applicationLifecycleArchitectureId = context id(
  architecturalRequirementIdCounter.at(<applicationLifecycleArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    applicationLifecycleArchitectureId,
    [Título],
    [Contrato de ciclo de vida],
    [Descripción],
    [Cada entrada debe ofrecer una operación para iniciar la aplicación en un contenedor con las opciones acordadas y devolver un control de ciclo de vida que permita finalizarla, quedando a juicio del usuario la interfaz concreta.],
  ),
  caption: [Requisito de arquitectura #applicationLifecycleArchitectureId],
) <applicationLifecycleArchitecture>

#architecturalRequirementIdCounter.step()
#let remoteResourceResolutionArchitectureId = context id(
  architecturalRequirementIdCounter.at(<remoteResourceResolutionArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    remoteResourceResolutionArchitectureId,
    [Título],
    [Resolución de recursos por instancia],
    [Descripción],
    [Al crear una instancia, el sistema debe facilitar que la misma sea capaz de resolver sus recursos dependientes con relación a la ubicación de publicación de la aplicación remota.],
  ),
  caption: [Requisito de arquitectura #remoteResourceResolutionArchitectureId],
) <remoteResourceResolutionArchitecture>

#architecturalRequirementIdCounter.step()
#let styleManagementArchitectureId = context id(
  architecturalRequirementIdCounter.at(<styleManagementArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    styleManagementArchitectureId,
    [Título],
    [Gestión de estilos],
    [Descripción],
    [El sistema debe asociar los estilos con sus aplicaciones o instancias y ofrecer una forma configurable de aplicarlos dentro de sus contenedores.],
  ),
  caption: [Requisito de arquitectura #styleManagementArchitectureId],
) <styleManagementArchitecture>

#architecturalRequirementIdCounter.step()
#let cooperativeExecutionArchitectureId = context id(
  architecturalRequirementIdCounter.at(<cooperativeExecutionArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    cooperativeExecutionArchitectureId,
    [Título],
    [Ejecución cooperativa],
    [Descripción],
    [La solución debe documentar el modelo de ejecución y los límites de aislamiento que ofrece, sin prometer garantías que no formen parte de su diseño.],
  ),
  caption: [Requisito de arquitectura #cooperativeExecutionArchitectureId],
) <cooperativeExecutionArchitecture>

#architecturalRequirementIdCounter.step()
#let typedCommunicationArchitectureId = context id(
  architecturalRequirementIdCounter.at(<typedCommunicationArchitecture>).at(0),
  ..architecturalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    typedCommunicationArchitectureId,
    [Título],
    [Contratos de comunicación],
    [Descripción],
    [Las capacidades de comunicación deben poder utilizarse independientemente de la carga de aplicaciones y basarse en contratos explícitos para los datos, las acciones y los eventos, que quedan a elección del usuario.],
  ),
  caption: [Requisito de arquitectura #typedCommunicationArchitectureId],
) <typedCommunicationArchitecture>

== Requisitos funcionales <functional-requirements>

#let functionalRequirementIdCounter = counter("functionalRequirement")
#let functionalRequirementIdParams = (prefix: "FR-", length: 2)

#functionalRequirementIdCounter.step()
#let configureRemoteBuildFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<configureRemoteBuildFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    configureRemoteBuildFunctionalRequirementId,
    [Título],
    [Configurar entradas remotas],
    [Descripción],
    [La integración con una herramienta de compilación debe aceptar una entrada o un conjunto de entradas con nombre, validar la configuración y producir los recursos requeridos para su publicación.],
  ),
  caption: [Requisito funcional #configureRemoteBuildFunctionalRequirementId],
) <configureRemoteBuildFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let generateRemoteEntryFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<generateRemoteEntryFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    generateRemoteEntryFunctionalRequirementId,
    [Título],
    [Preparar entradas para la integración],
    [Descripción],
    [El proceso de compilación debe producir recursos que permitan a la aplicación anfitriona descubrir las entradas declaradas y cargar el código y las dependencias asociados.],
  ),
  caption: [Requisito funcional #generateRemoteEntryFunctionalRequirementId],
) <generateRemoteEntryFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let loadRemoteEntryFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<loadRemoteEntryFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    loadRemoteEntryFunctionalRequirementId,
    [Título],
    [Cargar una aplicación remota],
    [Descripción],
    [La aplicación anfitriona debe poder solicitar una aplicación mediante su ubicación. Las solicitudes repetidas o concurrentes deben reutilizarse cuando sea seguro y puedan asociarse con la aplicación correcta.],
  ),
  caption: [Requisito funcional #loadRemoteEntryFunctionalRequirementId],
) <loadRemoteEntryFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let loadNamedAppInstanceFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<loadNamedAppInstanceFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    loadNamedAppInstanceFunctionalRequirementId,
    [Título],
    [Crear una instancia y seleccionar su entrada],
    [Descripción],
    [El sistema debe crear una instancia remota, resolver sus recursos relativos a la ubicación de publicación y seleccionar la entrada solicitada. Si no se especifica una, debe utilizar una entrada predeterminada definida por la especificación.],
  ),
  caption: [Requisito funcional #loadNamedAppInstanceFunctionalRequirementId],
) <loadNamedAppInstanceFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let mountRemoteAppFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<mountRemoteAppFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    mountRemoteAppFunctionalRequirementId,
    [Título],
    [Montar una aplicación],
    [Descripción],
    [La aplicación anfitriona debe poder solicitar que una aplicación remota inicie su interfaz en un contenedor y recibir un control para gestionar el ciclo de vida de esa instancia.],
  ),
  caption: [Requisito funcional #mountRemoteAppFunctionalRequirementId],
) <mountRemoteAppFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let unmountRemoteAppFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<unmountRemoteAppFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    unmountRemoteAppFunctionalRequirementId,
    [Título],
    [Desmontar una aplicación],
    [Descripción],
    [El control del ciclo de vida debe permitir finalizar la instancia y liberar sus recursos. La operación puede ser síncrona o asíncrona.],
  ),
  caption: [Requisito funcional #unmountRemoteAppFunctionalRequirementId],
) <unmountRemoteAppFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let manageApplicationStylesFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<manageApplicationStylesFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    manageApplicationStylesFunctionalRequirementId,
    [Título],
    [Gestionar estilos de las aplicaciones],
    [Descripción],
    [El sistema debe asociar los estilos necesarios con cada aplicación y aplicarlos a sus instancias activas, actualizando los ámbitos afectados cuando cambien esos recursos.],
  ),
  caption: [Requisito funcional #manageApplicationStylesFunctionalRequirementId],
) <manageApplicationStylesFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let limitStyleConflictsFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<limitStyleConflictsFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    limitStyleConflictsFunctionalRequirementId,
    [Título],
    [Reducir conflictos entre estilos],
    [Descripción],
    [El sistema debe ofrecer un mecanismo configurable para limitar el alcance de los estilos por aplicación o instancia y definir cómo se gestionan los estilos globales y los recursos compartidos.],
  ),
  caption: [Requisito funcional #limitStyleConflictsFunctionalRequirementId],
) <limitStyleConflictsFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let releaseStyleResourcesFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<releaseStyleResourcesFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    releaseStyleResourcesFunctionalRequirementId,
    [Título],
    [Liberar recursos de estilo],
    [Descripción],
    [El sistema debe permitir retirar los estilos asociados a una aplicación o instancia sin eliminar recursos que sigan siendo utilizados por otras.],
  ),
  caption: [Requisito funcional #releaseStyleResourcesFunctionalRequirementId],
) <releaseStyleResourcesFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let shareDataAndActionsFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<shareDataAndActionsFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    shareDataAndActionsFunctionalRequirementId,
    [Título],
    [Compartir datos y acciones],
    [Descripción],
    [Las aplicaciones deben poder intercambiar datos y solicitar acciones mediante un contrato acordado. Las interfaces de comunicación deben permitir observar cambios y cancelar suscripciones individuales o liberar las de una instancia.],
  ),
  caption: [Requisito funcional #shareDataAndActionsFunctionalRequirementId],
) <shareDataAndActionsFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let exchangeEventsFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<exchangeEventsFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    exchangeEventsFunctionalRequirementId,
    [Título],
    [Intercambiar eventos],
    [Descripción],
    [Las aplicaciones deben poder publicar y recibir eventos conforme a un contrato común que defina cada evento y su contenido. Debe ser posible cancelar suscripciones y liberar los recursos de comunicación.],
  ),
  caption: [Requisito funcional #exchangeEventsFunctionalRequirementId],
) <exchangeEventsFunctionalRequirement>

#functionalRequirementIdCounter.step()
#let loadFailureFunctionalRequirementId = context id(
  functionalRequirementIdCounter.at(<loadFailureFunctionalRequirement>).at(0),
  ..functionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    loadFailureFunctionalRequirementId,
    [Título],
    [Informar de entradas no disponibles],
    [Descripción],
    [Si no se puede obtener o inicializar una aplicación remota, el sistema debe informar del fallo, liberar los recursos temporales cuando sea posible y permitir un nuevo intento. Si falta una entrada solicitada, el error debe identificar la aplicación y las entradas disponibles cuando se conozcan.],
  ),
  caption: [Requisito funcional #loadFailureFunctionalRequirementId],
) <loadFailureFunctionalRequirement>

== Requisitos no funcionales <non-functional-requirements>

#let nonFunctionalRequirementIdCounter = counter("nonFunctionalRequirement")
#let nonFunctionalRequirementIdParams = (prefix: "RNF-", length: 2)

#nonFunctionalRequirementIdCounter.step()
#let frameworkNeutralityNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<frameworkNeutralityNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    frameworkNeutralityNonFunctionalRequirementId,
    [Título],
    [Independencia de framework],
    [Descripción],
    [El contrato de integración no debe exigir un framework de interfaz concreto a la aplicación anfitriona ni a las aplicaciones remotas.],
  ),
  caption: [Requisito no funcional #frameworkNeutralityNonFunctionalRequirementId],
) <frameworkNeutralityNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let cachingPerformanceNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<cachingPerformanceNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    cachingPerformanceNonFunctionalRequirementId,
    [Título],
    [Eficiencia de carga],
    [Descripción],
    [El sistema debe reutilizar de forma segura los recursos de una aplicación remota cuando se solicite más de una vez y permitir crear instancias con ciclos de vida independientes.],
  ),
  caption: [Requisito no funcional #cachingPerformanceNonFunctionalRequirementId],
) <cachingPerformanceNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let concurrentLoadsNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<concurrentLoadsNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    concurrentLoadsNonFunctionalRequirementId,
    [Título],
    [Seguridad ante concurrencia],
    [Descripción],
    [Las solicitudes concurrentes deben asociarse con la aplicación y el resultado correctos, y no deben corromper el estado compartido del sistema.],
  ),
  caption: [Requisito no funcional #concurrentLoadsNonFunctionalRequirementId],
) <concurrentLoadsNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let resourceCleanupNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<resourceCleanupNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    resourceCleanupNonFunctionalRequirementId,
    [Título],
    [Liberación de recursos],
    [Descripción],
    [Las operaciones de finalización, cancelación de suscripciones y liberación de estilos deben permitir retirar los recursos creados durante una instancia. Cada aplicación debe completar la limpieza que le corresponda.],
  ),
  caption: [Requisito no funcional #resourceCleanupNonFunctionalRequirementId],
) <resourceCleanupNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let styleIsolationNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<styleIsolationNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    styleIsolationNonFunctionalRequirementId,
    [Título],
    [Aislamiento visual],
    [Descripción],
    [Los mecanismos de alcance de estilos deben reducir las interferencias visuales entre aplicaciones cuando se habiliten.],
  ),
  caption: [Requisito no funcional #styleIsolationNonFunctionalRequirementId],
) <styleIsolationNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let typeSafetyNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<typeSafetyNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    typeSafetyNonFunctionalRequirementId,
    [Título],
    [Contratos claros],
    [Descripción],
    [Las interfaces públicas deben definir contratos claros y coherentes que faciliten detectar incompatibilidades durante el desarrollo.],
  ),
  caption: [Requisito no funcional #typeSafetyNonFunctionalRequirementId],
) <typeSafetyNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let trustedRemotesNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<trustedRemotesNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    trustedRemotesNonFunctionalRequirementId,
    [Título],
    [Confianza de aplicaciones remotas],
    [Descripción],
    [La aplicación anfitriona debe aplicar una política de confianza a las aplicaciones remotas y basar sus expectativas de seguridad en los límites de aislamiento que el sistema defina explícitamente.],
  ),
  caption: [Requisito no funcional #trustedRemotesNonFunctionalRequirementId],
) <trustedRemotesNonFunctionalRequirement>

#nonFunctionalRequirementIdCounter.step()
#let browserRequirementsNonFunctionalRequirementId = context id(
  nonFunctionalRequirementIdCounter.at(<browserRequirementsNonFunctionalRequirement>).at(0),
  ..nonFunctionalRequirementIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    browserRequirementsNonFunctionalRequirementId,
    [Título],
    [Entornos compatibles],
    [Descripción],
    [La solución debe documentar los entornos de ejecución y las capacidades de plataforma requeridas, así como las herramientas de compilación compatibles.],
  ),
  caption: [Requisito no funcional #browserRequirementsNonFunctionalRequirementId],
) <browserRequirementsNonFunctionalRequirement>

== Casos de uso <use-cases>

Los casos de uso detallan cómo los actores emplean las capacidades descritas en las tablas anteriores. Sus identificadores se generan de forma independiente.

#let useCaseIdCounter = counter("useCase")
#let useCaseIdParams = (prefix: "UC-", length: 2)

#useCaseIdCounter.step()
#let buildRemoteUseCaseId = context id(useCaseIdCounter.at(<buildRemoteUseCase>).at(0), ..useCaseIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    buildRemoteUseCaseId,
    [Nombre],
    [Compilar y publicar una aplicación remota],
    [Actores],
    [#remoteAppDeveloperActorId, #remoteServerActorId],
    [Precondiciones],
    [El proyecto remoto dispone de una o varias entradas de aplicación y utiliza una herramienta de compilación compatible.],
    [Flujo principal],
    [
      1. El desarrollador configura la integración de compilación con las entradas que desea publicar. \
      2. El proceso de compilación prepara las entradas y los recursos necesarios para su carga. \
      3. El desarrollador publica esos recursos en una ubicación accesible para la aplicación anfitriona.
    ],
    [Postcondiciones],
    [La aplicación remota queda disponible en una URL que puede cargar la aplicación anfitriona.],
  ),
  caption: [Caso de uso #buildRemoteUseCaseId],
) <buildRemoteUseCase>

#useCaseIdCounter.step()
#let loadAndMountUseCaseId = context id(useCaseIdCounter.at(<loadAndMountUseCase>).at(0), ..useCaseIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    loadAndMountUseCaseId,
    [Nombre],
    [Cargar y montar una entrada remota],
    [Actores],
    [#hostAppDeveloperActorId, #remoteServerActorId, #browserActorId],
    [Precondiciones],
    [La entrada remota está publicada y la aplicación anfitriona dispone de un elemento contenedor.],
    [Flujo principal],
    [
      1. La aplicación anfitriona solicita una aplicación remota mediante su ubicación y, si es necesario, indica la entrada que desea utilizar. \
      2. El sistema resuelve la aplicación y prepara una instancia con sus recursos asociados. \
      3. La aplicación anfitriona solicita que la instancia inicie su interfaz en un contenedor. \
      4. La aplicación presenta su interfaz y devuelve el control de ciclo de vida de la instancia.
    ],
    [Postcondiciones],
    [La aplicación remota queda montada y devuelve el ciclo de vida para desmontarla.],
    [Excepción],
    [Si no se puede obtener o inicializar la aplicación, o no existe la entrada solicitada, el sistema informa del error y no devuelve una instancia iniciada.],
  ),
  caption: [Caso de uso #loadAndMountUseCaseId],
) <loadAndMountUseCase>

#useCaseIdCounter.step()
#let mountMultipleInstancesUseCaseId = context id(
  useCaseIdCounter.at(<mountMultipleInstancesUseCase>).at(0),
  ..useCaseIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    mountMultipleInstancesUseCaseId,
    [Nombre],
    [Montar varias instancias de una aplicación],
    [Actores],
    [#hostAppDeveloperActorId, #remoteServerActorId],
    [Precondiciones],
    [La entrada remota admite más de una instancia y la aplicación anfitriona dispone de varios contenedores.],
    [Flujo principal],
    [
      1. La aplicación anfitriona solicita la misma aplicación remota para varios contenedores. \
      2. El sistema reutiliza los recursos compartidos cuando sea posible. \
      3. Cada solicitud crea una instancia y un control de ciclo de vida independientes. \
      4. La aplicación anfitriona finaliza cada instancia por separado.
    ],
    [Postcondiciones],
    [Los recursos compartidos se reutilizan cuando es seguro y cada instancia puede gestionarse de forma independiente.],
  ),
  caption: [Caso de uso #mountMultipleInstancesUseCaseId],
) <mountMultipleInstancesUseCase>

#useCaseIdCounter.step()
#let loadNamedEntryUseCaseId = context id(useCaseIdCounter.at(<loadNamedEntryUseCase>).at(0), ..useCaseIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    loadNamedEntryUseCaseId,
    [Nombre],
    [Seleccionar una entrada remota],
    [Actores],
    [#hostAppDeveloperActorId, #remoteAppDeveloperActorId],
    [Precondiciones],
    [La aplicación remota declara una o varias entradas identificables.],
    [Flujo principal],
    [
      1. La aplicación anfitriona solicita una aplicación remota. \
      2. La aplicación anfitriona selecciona una entrada declarada mediante la interfaz de carga disponible. \
      3. El sistema devuelve la entrada seleccionada lista para iniciar su interfaz.
    ],
    [Postcondiciones],
    [La aplicación anfitriona obtiene la interfaz de montaje de la entrada seleccionada.],
    [Excepción],
    [Si la entrada solicitada no existe, el error identifica la aplicación y enumera las entradas disponibles cuando se conocen.],
  ),
  caption: [Caso de uso #loadNamedEntryUseCaseId],
) <loadNamedEntryUseCase>

#useCaseIdCounter.step()
#let useStandaloneEntryUseCaseId = context id(useCaseIdCounter.at(<useStandaloneEntryUseCase>).at(0), ..useCaseIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    useStandaloneEntryUseCaseId,
    [Nombre],
    [Ejecutar la aplicación de forma autónoma],
    [Actores],
    [#remoteAppDeveloperActorId, #endUserActorId, #browserActorId],
    [Precondiciones],
    [La aplicación remota incluye una forma de iniciarse sin una aplicación anfitriona.],
    [Flujo principal],
    [
      1. El usuario abre la ubicación publicada de la aplicación. \
      2. La aplicación inicia su interfaz sin que otra aplicación la haya cargado.
    ],
    [Postcondiciones],
    [La aplicación funciona sin que otra aplicación anfitriona la haya cargado.],
  ),
  caption: [Caso de uso #useStandaloneEntryUseCaseId],
) <useStandaloneEntryUseCase>

#useCaseIdCounter.step()
#let isolateStylesUseCaseId = context id(useCaseIdCounter.at(<isolateStylesUseCase>).at(0), ..useCaseIdParams)
#figure(
  twoColumnTable(
    [Identificador],
    isolateStylesUseCaseId,
    [Nombre],
    [Aislar los estilos de una aplicación],
    [Actores],
    [#remoteAppDeveloperActorId, #browserActorId],
    [Precondiciones],
    [La aplicación remota declara sus estilos y recibe un contenedor para presentar su interfaz.],
    [Flujo principal],
    [
      1. La aplicación solicita un ámbito de estilos para el contenedor donde presentará su interfaz. \
      2. El sistema aplica los estilos asociados conforme a la configuración de alcance elegida. \
      3. Los cambios en los estilos se reflejan en las instancias afectadas cuando corresponda. \
      4. Al finalizar la instancia, la aplicación solicita la liberación de los recursos de estilo que ya no necesita.
    ],
    [Postcondiciones],
    [Los estilos quedan asociados al contenedor remoto y pueden retirarse al desmontar.],
  ),
  caption: [Caso de uso #isolateStylesUseCaseId],
) <isolateStylesUseCase>

#useCaseIdCounter.step()
#let communicateThroughDataChannelUseCaseId = context id(
  useCaseIdCounter.at(<communicateThroughDataChannelUseCase>).at(0),
  ..useCaseIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    communicateThroughDataChannelUseCaseId,
    [Nombre],
    [Compartir datos y acciones entre aplicaciones],
    [Actores],
    [#hostAppDeveloperActorId, #remoteAppDeveloperActorId],
    [Precondiciones],
    [La aplicación anfitriona y la remota acuerdan un contrato para compartir datos y acciones.],
    [Flujo principal],
    [
      1. La aplicación anfitriona establece un canal de comunicación y lo comparte con las aplicaciones participantes. \
      2. Las aplicaciones intercambian datos, observan cambios y solicitan las acciones acordadas. \
      3. Cada aplicación cancela las suscripciones que deja de necesitar.
    ],
    [Postcondiciones],
    [Las aplicaciones intercambian datos y solicitudes mediante un canal de comunicación acordado.],
  ),
  caption: [Caso de uso #communicateThroughDataChannelUseCaseId],
) <communicateThroughDataChannelUseCase>

#useCaseIdCounter.step()
#let communicateThroughEventsUseCaseId = context id(
  useCaseIdCounter.at(<communicateThroughEventsUseCase>).at(0),
  ..useCaseIdParams,
)
#figure(
  twoColumnTable(
    [Identificador],
    communicateThroughEventsUseCaseId,
    [Nombre],
    [Comunicar aplicaciones mediante eventos],
    [Actores],
    [#hostAppDeveloperActorId, #remoteAppDeveloperActorId],
    [Precondiciones],
    [Las aplicaciones comparten un canal de eventos y acuerdan los eventos y contenidos que intercambiarán.],
    [Flujo principal],
    [
      1. La aplicación anfitriona establece un canal de eventos y lo comparte con las aplicaciones participantes. \
      2. Cada aplicación se suscribe a los eventos que necesita recibir. \
      3. Una aplicación publica un evento y las suscriptoras procesan su contenido. \
      4. Las aplicaciones cancelan sus suscripciones al finalizar y el propietario libera el canal cuando deja de usarse.
    ],
    [Postcondiciones],
    [Las aplicaciones relacionadas intercambian eventos sin referencias directas entre todos sus participantes.],
  ),
  caption: [Caso de uso #communicateThroughEventsUseCaseId],
) <communicateThroughEventsUseCase>
