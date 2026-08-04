(function () {
  "use strict";

  var STORAGE_KEY = "bol.legal.lang";

  var LANGS = [
    { code: "en", label: "English" },
    { code: "es", label: "Español" },
    { code: "ca", label: "Català" },
    { code: "eu", label: "Euskara" },
    { code: "gl", label: "Galego" },
    { code: "pt", label: "Português" },
    { code: "it", label: "Italiano" },
  ];

  var T = {
    en: {
      brand: "Böl",
      navTerms: "Terms and Conditions",
      navPrivacy: "Privacy Policy",
      langLabel: "Language",
      footer: "© 2026 Böl",
      updated: "Last updated: June 2026",

      indexTitle: "Böl — Legal information",
      indexH1: "Legal information",
      indexIntro:
        "Böl is an app for weekly meal planning and shopping lists. Here you will find the legal documents that apply to the service.",
      indexTermsCardTitle: "Terms and Conditions",
      indexTermsCardDesc: "Terms of use for the application and the service.",
      indexPrivacyCardTitle: "Privacy Policy",
      indexPrivacyCardDesc:
        "How we process your personal data under the GDPR and your rights, including account deletion.",

      termsTitle: "Terms and Conditions — Böl",
      termsH1: "Terms and Conditions",
      terms1H: "1. Acceptance",
      terms1P:
        "By registering for or using Böl (“the App”), you accept these Terms and Conditions. If you do not agree, do not use the service.",
      terms2H: "2. Service description",
      terms2P:
        "Böl lets you manage a personal recipe book, plan weekly meals, generate shopping lists and, optionally, share a household with other users to collaborate on the planner and the list.",
      terms3H: "3. User account",
      terms3L1: "You must provide accurate information when registering.",
      terms3L2: "You are responsible for keeping your credentials confidential.",
      terms3L3: "You must report any unauthorized use of your account.",
      terms3L4:
        "You may delete your account at any time from the App (see the Privacy Policy).",
      terms4H: "4. Acceptable use",
      terms4P: "You agree not to:",
      terms4L1: "Use the App for unlawful purposes or in ways that infringe third-party rights.",
      terms4L2: "Attempt unauthorized access to systems, data or other accounts.",
      terms4L3: "Interfere with the service or overload the infrastructure.",
      terms4L4: "Upload offensive, illegal content or content that infringes intellectual property.",
      terms5H: "5. User content",
      terms5P:
        "You retain ownership of recipes, photos and other content you upload. You grant us a limited licence to store, process and display that content solely to provide the service.",
      terms6H: "6. Shared households",
      terms6P:
        "If you join a household, other members may view and edit the shared planner and shopping list. Leave the household or delete your account if you no longer wish to share data with that group.",
      terms7H: "7. Availability and changes",
      terms7P:
        "The service is provided “as is”. We may change features, temporarily suspend or discontinue the service, and update these terms. Relevant changes will be communicated by reasonable means (e.g. in the App or on this page).",
      terms8H: "8. Limitation of liability",
      terms8P:
        "Böl is a household organisation tool. It does not replace medical, nutritional or food-safety advice. We are not liable for indirect damages arising from use of the App to the extent permitted by applicable law.",
      terms9H: "9. Governing law",
      terms9P:
        "These terms are governed by applicable Spanish and European law. For consumer claims you may use the dispute-resolution mechanisms available in your jurisdiction.",
      terms10H: "10. Contact",
      terms10P:
        "For questions about these terms: open an issue in the project’s public GitHub repository or contact the service operator listed on the app store listing.",

      privacyTitle: "Privacy Policy — Böl",
      privacyH1: "Privacy Policy",
      privacy1H: "1. Data controller",
      privacy1P:
        "The controller of personal data associated with Böl is the project owner, contactable via the GitHub repository or the app store listing.",
      privacy2H: "2. Data we collect",
      privacy2L1:
        "<strong>Account:</strong> email, display name, authentication identifiers (e.g. Google or Apple).",
      privacy2L2: "<strong>Profile:</strong> avatar (optional).",
      privacy2L3:
        "<strong>Content:</strong> recipes, ingredients, weekly planner, shopping lists.",
      privacy2L4:
        "<strong>Shared household:</strong> membership and household name if you create or join one.",
      privacy2L5:
        "<strong>Technical:</strong> aggregated usage data (Firebase Analytics), errors (Sentry) and diagnostic logs.",
      privacy3H: "3. Purpose and legal basis",
      privacy3L1: "Providing the service (contract performance / legitimate interest).",
      privacy3L2: "Authentication and account security (legitimate interest).",
      privacy3L3:
        "Product improvement and stability (legitimate interest / consent where applicable).",
      privacy3L4: "Compliance with legal obligations.",
      privacy4H: "4. Processors and transfers",
      privacy4P: "We use providers that process data on our behalf:",
      privacy4L1:
        "<strong>Supabase</strong> — database, authentication and storage (EU, eu-west-1).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — usage analytics.",
      privacy4L3: "<strong>Sentry</strong> — error monitoring.",
      privacy4L4:
        "<strong>Google / Apple</strong> — OAuth sign-in when you choose it.",
      privacy4P2:
        "These providers may be subject to standard contractual clauses or other GDPR-recognised safeguards.",
      privacy5H: "5. Retention",
      privacy5P:
        "We keep your data while your account remains active. After account deletion, we delete or anonymise personal data within a reasonable period, unless a legal retention duty applies.",
      privacy6H: "6. Your rights (GDPR)",
      privacy6P: "You have the right to:",
      privacy6L1: "Access, rectify and erase your data.",
      privacy6L2: "Restrict or object to certain processing.",
      privacy6L3: "Data portability for data you have provided.",
      privacy6L4: "Withdraw consent where processing is based on it.",
      privacy6L5: "Lodge a complaint with the AEPD or another competent authority.",
      privacy6P2:
        "You can exercise <strong>account deletion</strong> directly in the App: Profile → Delete account. This action is irreversible and removes your profile, recipes and associated data from our systems.",
      privacy7H: "7. Minors",
      privacy7P:
        "The service is not directed at children under 16. If we detect an account of a minor without verifiable parental consent, we may delete it.",
      privacy8H: "8. Security",
      privacy8P:
        "We apply reasonable technical and organisational measures (encryption in transit, access control, secure session storage on device). No system is 100% secure.",
      privacy9H: "9. Changes",
      privacy9P:
        "We may update this policy. The “last updated” date will reflect the current version. Continued use after material changes constitutes acceptance where the law allows.",
      privacy10H: "10. Contact",
      privacy10P:
        "To exercise your rights or for privacy questions, use account deletion in the App or contact us via the project’s GitHub repository.",
    },

    es: {
      brand: "Böl",
      navTerms: "Términos y Condiciones",
      navPrivacy: "Política de Privacidad",
      langLabel: "Idioma",
      footer: "© 2026 Böl",
      updated: "Última actualización: junio de 2026",

      indexTitle: "Böl — Información legal",
      indexH1: "Información legal",
      indexIntro:
        "Böl es una aplicación para planificar comidas semanales y generar listas de la compra. Aquí encontrarás los documentos legales aplicables al uso del servicio.",
      indexTermsCardTitle: "Términos y Condiciones",
      indexTermsCardDesc: "Condiciones de uso de la aplicación y del servicio.",
      indexPrivacyCardTitle: "Política de Privacidad",
      indexPrivacyCardDesc:
        "Cómo tratamos tus datos personales conforme al RGPD y tus derechos, incluida la supresión de la cuenta.",

      termsTitle: "Términos y Condiciones — Böl",
      termsH1: "Términos y Condiciones",
      terms1H: "1. Aceptación",
      terms1P:
        "Al registrarte o utilizar Böl («la App»), aceptas estos Términos y Condiciones. Si no estás de acuerdo, no uses el servicio.",
      terms2H: "2. Descripción del servicio",
      terms2P:
        "Böl permite gestionar un recetario personal, planificar comidas semanales, generar listas de la compra y, opcionalmente, compartir un hogar con otros usuarios para colaborar en el planificador y la lista.",
      terms3H: "3. Cuenta de usuario",
      terms3L1: "Debes proporcionar información veraz al registrarte.",
      terms3L2: "Eres responsable de mantener la confidencialidad de tus credenciales.",
      terms3L3: "Debes notificar cualquier uso no autorizado de tu cuenta.",
      terms3L4:
        "Puedes eliminar tu cuenta en cualquier momento desde la App (ver Política de Privacidad).",
      terms4H: "4. Uso aceptable",
      terms4P: "Te comprometes a no:",
      terms4L1: "Usar la App con fines ilícitos o que vulneren derechos de terceros.",
      terms4L2: "Intentar acceder sin autorización a sistemas, datos o cuentas ajenas.",
      terms4L3: "Interferir en el funcionamiento del servicio o sobrecargar la infraestructura.",
      terms4L4: "Subir contenido ofensivo, ilegal o que infrinja propiedad intelectual.",
      terms5H: "5. Contenido del usuario",
      terms5P:
        "Conservas la titularidad de las recetas, fotos y demás contenido que subas. Nos concedes una licencia limitada para almacenar, procesar y mostrar ese contenido únicamente con el fin de prestar el servicio.",
      terms6H: "6. Hogares compartidos",
      terms6P:
        "Si te unes a un hogar, los demás miembros podrán ver y editar el planificador y la lista de la compra compartidos. Abandona el hogar o elimina tu cuenta si ya no deseas compartir datos con ese grupo.",
      terms7H: "7. Disponibilidad y cambios",
      terms7P:
        "El servicio se ofrece «tal cual». Podemos modificar funcionalidades, suspender temporalmente o interrumpir el servicio, y actualizar estos términos. Los cambios relevantes se comunicarán por medios razonables (p. ej. en la App o en esta página).",
      terms8H: "8. Limitación de responsabilidad",
      terms8P:
        "Böl es una herramienta de organización doméstica. No sustituye asesoramiento médico, nutricional o de seguridad alimentaria. No nos hacemos responsables de daños indirectos derivados del uso de la App en la medida permitida por la ley aplicable.",
      terms9H: "9. Ley aplicable",
      terms9P:
        "Estos términos se rigen por la legislación española y europea aplicable. Para reclamaciones de consumo puedes acudir a los mecanismos de resolución de conflictos previstos en tu jurisdicción.",
      terms10H: "10. Contacto",
      terms10P:
        "Para consultas sobre estos términos: abre un issue en el repositorio público del proyecto en GitHub o contacta al responsable del servicio indicado en la ficha de la tienda de aplicaciones.",

      privacyTitle: "Política de Privacidad — Böl",
      privacyH1: "Política de Privacidad",
      privacy1H: "1. Responsable del tratamiento",
      privacy1P:
        "El responsable del tratamiento de los datos personales asociados a Böl es el titular del proyecto, contactable a través del repositorio en GitHub o la ficha de la tienda de aplicaciones.",
      privacy2H: "2. Datos que recogemos",
      privacy2L1:
        "<strong>Cuenta:</strong> correo electrónico, nombre de usuario, identificadores de autenticación (p. ej. Google o Apple).",
      privacy2L2: "<strong>Perfil:</strong> avatar (opcional).",
      privacy2L3:
        "<strong>Contenido:</strong> recetas, ingredientes, planificador semanal, listas de la compra.",
      privacy2L4:
        "<strong>Hogar compartido:</strong> membresía y nombre del hogar si decides crearlo o unirte.",
      privacy2L5:
        "<strong>Técnicos:</strong> datos de uso agregados (Firebase Analytics), errores (Sentry) y logs de diagnóstico.",
      privacy3H: "3. Finalidad y base legal",
      privacy3L1: "Prestación del servicio (ejecución del contrato / interés legítimo).",
      privacy3L2: "Autenticación y seguridad de la cuenta (interés legítimo).",
      privacy3L3:
        "Mejora del producto y estabilidad (interés legítimo / consentimiento cuando aplique).",
      privacy3L4: "Cumplimiento de obligaciones legales.",
      privacy4H: "4. Encargados y transferencias",
      privacy4P: "Utilizamos proveedores que tratan datos en nuestro nombre:",
      privacy4L1:
        "<strong>Supabase</strong> — base de datos, autenticación y almacenamiento (UE, región eu-west-1).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — analítica de uso.",
      privacy4L3: "<strong>Sentry</strong> — monitorización de errores.",
      privacy4L4:
        "<strong>Google / Apple</strong> — inicio de sesión OAuth cuando lo eliges.",
      privacy4P2:
        "Estos proveedores pueden estar sujetos a cláusulas contractuales tipo u otras garantías reconocidas por el RGPD.",
      privacy5H: "5. Conservación",
      privacy5P:
        "Conservamos tus datos mientras mantengas una cuenta activa. Tras la eliminación de la cuenta, borramos o anonimizamos los datos personales en un plazo razonable, salvo obligación legal de conservación.",
      privacy6H: "6. Tus derechos (RGPD)",
      privacy6P: "Tienes derecho a:",
      privacy6L1: "Acceder, rectificar y suprimir tus datos.",
      privacy6L2: "Limitar u oponerte a determinados tratamientos.",
      privacy6L3: "Portabilidad de los datos que nos hayas facilitado.",
      privacy6L4: "Retirar el consentimiento cuando el tratamiento se base en él.",
      privacy6L5: "Presentar reclamación ante la AEPD u otra autoridad competente.",
      privacy6P2:
        "Puedes ejercer la <strong>supresión de la cuenta</strong> directamente en la App: Perfil → Eliminar cuenta. Esta acción es irreversible y elimina tu perfil, recetas y datos asociados en nuestros sistemas.",
      privacy7H: "7. Menores",
      privacy7P:
        "El servicio no está dirigido a menores de 16 años. Si detectamos una cuenta de un menor sin consentimiento parental verificable, podremos eliminarla.",
      privacy8H: "8. Seguridad",
      privacy8P:
        "Aplicamos medidas técnicas y organizativas razonables (cifrado en tránsito, control de acceso, almacenamiento seguro de sesión en el dispositivo). Ningún sistema es 100 % seguro.",
      privacy9H: "9. Cambios",
      privacy9P:
        "Podemos actualizar esta política. La fecha de «última actualización» reflejará la versión vigente. El uso continuado tras cambios relevantes implica su aceptación cuando la ley lo permita.",
      privacy10H: "10. Contacto",
      privacy10P:
        "Para ejercer tus derechos o consultas de privacidad, utiliza la eliminación de cuenta en la App o contacta a través del repositorio del proyecto en GitHub.",
    },

    ca: {
      brand: "Böl",
      navTerms: "Termes i Condicions",
      navPrivacy: "Política de Privacitat",
      langLabel: "Idioma",
      footer: "© 2026 Böl",
      updated: "Darrera actualització: juny de 2026",

      indexTitle: "Böl — Informació legal",
      indexH1: "Informació legal",
      indexIntro:
        "Böl és una aplicació per planificar àpats setmanals i generar llistes de la compra. Aquí trobaràs els documents legals aplicables a l’ús del servei.",
      indexTermsCardTitle: "Termes i Condicions",
      indexTermsCardDesc: "Condicions d’ús de l’aplicació i del servei.",
      indexPrivacyCardTitle: "Política de Privacitat",
      indexPrivacyCardDesc:
        "Com tractem les teves dades personals d’acord amb el RGPD i els teus drets, inclosa la supressió del compte.",

      termsTitle: "Termes i Condicions — Böl",
      termsH1: "Termes i Condicions",
      terms1H: "1. Acceptació",
      terms1P:
        "En registrar-te o utilitzar Böl («l’App»), acceptes aquests Termes i Condicions. Si no hi estàs d’acord, no facis servir el servei.",
      terms2H: "2. Descripció del servei",
      terms2P:
        "Böl permet gestionar un receptari personal, planificar àpats setmanals, generar llistes de la compra i, opcionalment, compartir una llar amb altres usuaris per col·laborar al planificador i a la llista.",
      terms3H: "3. Compte d’usuari",
      terms3L1: "Has de proporcionar informació veraç en registrar-te.",
      terms3L2: "Ets responsable de mantenir la confidencialitat de les teves credencials.",
      terms3L3: "Has de notificar qualsevol ús no autoritzat del teu compte.",
      terms3L4:
        "Pots eliminar el teu compte en qualsevol moment des de l’App (vegeu la Política de Privacitat).",
      terms4H: "4. Ús acceptable",
      terms4P: "Et compromets a no:",
      terms4L1: "Utilitzar l’App amb finalitats il·lícites o que vulnerin drets de tercers.",
      terms4L2: "Intentar accedir sense autorització a sistemes, dades o comptes aliens.",
      terms4L3: "Interferir en el funcionament del servei o sobrecarregar la infraestructura.",
      terms4L4: "Pujar contingut ofensiu, il·legal o que infringeixi propietat intel·lectual.",
      terms5H: "5. Contingut de l’usuari",
      terms5P:
        "Conserves la titularitat de les receptes, fotos i altre contingut que pugis. Ens concedeixes una llicència limitada per emmagatzemar, processar i mostrar aquest contingut únicament amb la finalitat de prestar el servei.",
      terms6H: "6. Llars compartides",
      terms6P:
        "Si t’uneixes a una llar, els altres membres podran veure i editar el planificador i la llista de la compra compartits. Abandona la llar o elimina el teu compte si ja no vols compartir dades amb aquest grup.",
      terms7H: "7. Disponibilitat i canvis",
      terms7P:
        "El servei s’ofereix «tal qual». Podem modificar funcionalitats, suspendre temporalment o interrompre el servei, i actualitzar aquests termes. Els canvis rellevants es comunicaran per mitjans raonables (p. ex. a l’App o en aquesta pàgina).",
      terms8H: "8. Limitació de responsabilitat",
      terms8P:
        "Böl és una eina d’organització domèstica. No substitueix assessorament mèdic, nutricional o de seguretat alimentària. No ens fem responsables de danys indirectes derivats de l’ús de l’App en la mesura permesa per la llei aplicable.",
      terms9H: "9. Llei aplicable",
      terms9P:
        "Aquests termes es regeixen per la legislació espanyola i europea aplicable. Per a reclamacions de consum pots acudir als mecanismes de resolució de conflictes previstos a la teva jurisdicció.",
      terms10H: "10. Contacte",
      terms10P:
        "Per a consultes sobre aquests termes: obre un issue al repositori públic del projecte a GitHub o contacta el responsable del servei indicat a la fitxa de la botiga d’aplicacions.",

      privacyTitle: "Política de Privacitat — Böl",
      privacyH1: "Política de Privacitat",
      privacy1H: "1. Responsable del tractament",
      privacy1P:
        "El responsable del tractament de les dades personals associades a Böl és el titular del projecte, contactable a través del repositori a GitHub o la fitxa de la botiga d’aplicacions.",
      privacy2H: "2. Dades que recollim",
      privacy2L1:
        "<strong>Compte:</strong> correu electrònic, nom d’usuari, identificadors d’autenticació (p. ex. Google o Apple).",
      privacy2L2: "<strong>Perfil:</strong> avatar (opcional).",
      privacy2L3:
        "<strong>Contingut:</strong> receptes, ingredients, planificador setmanal, llistes de la compra.",
      privacy2L4:
        "<strong>Llar compartida:</strong> membresia i nom de la llar si decides crear-la o unir-t’hi.",
      privacy2L5:
        "<strong>Tècnics:</strong> dades d’ús agregades (Firebase Analytics), errors (Sentry) i registres de diagnòstic.",
      privacy3H: "3. Finalitat i base legal",
      privacy3L1: "Prestació del servei (execució del contracte / interès legítim).",
      privacy3L2: "Autenticació i seguretat del compte (interès legítim).",
      privacy3L3:
        "Millora del producte i estabilitat (interès legítim / consentiment quan escaigui).",
      privacy3L4: "Compliment d’obligacions legals.",
      privacy4H: "4. Encarregats i transferències",
      privacy4P: "Utilitzem proveïdors que tracten dades en nom nostre:",
      privacy4L1:
        "<strong>Supabase</strong> — base de dades, autenticació i emmagatzematge (UE, regió eu-west-1).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — analítica d’ús.",
      privacy4L3: "<strong>Sentry</strong> — monitoratge d’errors.",
      privacy4L4:
        "<strong>Google / Apple</strong> — inici de sessió OAuth quan l’esculls.",
      privacy4P2:
        "Aquests proveïdors poden estar subjectes a clàusules contractuals tipus o altres garanties reconegudes pel RGPD.",
      privacy5H: "5. Conservació",
      privacy5P:
        "Conservem les teves dades mentre mantinguis un compte actiu. Després de l’eliminació del compte, esborrem o anonimitzem les dades personals en un termini raonable, llevat d’obligació legal de conservació.",
      privacy6H: "6. Els teus drets (RGPD)",
      privacy6P: "Tens dret a:",
      privacy6L1: "Accedir, rectificar i suprimir les teves dades.",
      privacy6L2: "Limitar o oposar-te a determinats tractaments.",
      privacy6L3: "Portabilitat de les dades que ens hagis facilitat.",
      privacy6L4: "Retirar el consentiment quan el tractament es basi en ell.",
      privacy6L5: "Presentar reclamació davant l’AEPD o una altra autoritat competent.",
      privacy6P2:
        "Pots exercir la <strong>supressió del compte</strong> directament a l’App: Perfil → Eliminar compte. Aquesta acció és irreversible i elimina el teu perfil, receptes i dades associades als nostres sistemes.",
      privacy7H: "7. Menors",
      privacy7P:
        "El servei no està adreçat a menors de 16 anys. Si detectem un compte d’un menor sense consentiment parental verificable, podrem eliminar-lo.",
      privacy8H: "8. Seguretat",
      privacy8P:
        "Apliquem mesures tècniques i organitzatives raonables (xifratge en trànsit, control d’accés, emmagatzematge segur de sessió al dispositiu). Cap sistema és 100 % segur.",
      privacy9H: "9. Canvis",
      privacy9P:
        "Podem actualitzar aquesta política. La data de «darrera actualització» reflectirà la versió vigent. L’ús continuat després de canvis rellevants implica la seva acceptació quan la llei ho permeti.",
      privacy10H: "10. Contacte",
      privacy10P:
        "Per exercir els teus drets o consultes de privacitat, utilitza l’eliminació de compte a l’App o contacta a través del repositori del projecte a GitHub.",
    },

    eu: {
      brand: "Böl",
      navTerms: "Baldintzak eta Terminoak",
      navPrivacy: "Pribatutasun Politika",
      langLabel: "Hizkuntza",
      footer: "© 2026 Böl",
      updated: "Azken eguneratzea: 2026ko ekaina",

      indexTitle: "Böl — Informazio juridikoa",
      indexH1: "Informazio juridikoa",
      indexIntro:
        "Böl astean zehar otorduak planifikatzeko eta erosketa-zerrendak sortzeko aplikazio bat da. Hemen zerbitzuaren erabilerari aplikatzen zaizkion dokumentu juridikoak aurkituko dituzu.",
      indexTermsCardTitle: "Baldintzak eta Terminoak",
      indexTermsCardDesc: "Aplikazioaren eta zerbitzuaren erabilera-baldintzak.",
      indexPrivacyCardTitle: "Pribatutasun Politika",
      indexPrivacyCardDesc:
        "Nola tratatzen ditugun zure datu pertsonalak RGPD-aren arabera eta zure eskubideak, kontua ezabatzea barne.",

      termsTitle: "Baldintzak eta Terminoak — Böl",
      termsH1: "Baldintzak eta Terminoak",
      terms1H: "1. Onarpena",
      terms1P:
        "Böl («Appa») erregistratzean edo erabiltzean, Baldintza eta Termino hauek onartzen dituzu. Ados ez bazaude, ez erabili zerbitzua.",
      terms2H: "2. Zerbitzuaren deskribapena",
      terms2P:
        "Böl-ek errezeta-liburu pertsonala kudeatzeko, astean zehar otorduak planifikatzeko, erosketa-zerrendak sortzeko eta, nahi izanez gero, etxe bat beste erabiltzaileekin partekatzeko aukera ematen du, planifikatzailean eta zerrendan elkarlanean aritzeko.",
      terms3H: "3. Erabiltzaile-kontua",
      terms3L1: "Erregistroan informazio egiazkoa eman behar duzu.",
      terms3L2: "Zure kredentzialen konfidentzialtasuna mantentzeaz arduratzen zara.",
      terms3L3: "Zure kontuaren baimenik gabeko erabilera oro jakinarazi behar duzu.",
      terms3L4:
        "Kontua edozein unetan ezabatu dezakezu Appetik (ikus Pribatutasun Politika).",
      terms4H: "4. Erabilera onargarria",
      terms4P: "Honako hau ez egitea onartzen duzu:",
      terms4L1: "Appa legez kanpoko helburuetarako edo hirugarrenen eskubideak urratzen dituztenetarako erabiltzea.",
      terms4L2: "Sistemetara, datuetara edo besteen kontuetara baimenik gabe sartzen saiatzea.",
      terms4L3: "Zerbitzuaren funtzionamenduan esku hartzea edo azpiegitura gainkargatzea.",
      terms4L4: "Eduki iraingarria, legez kanpokoa edo jabetza intelektualaren aurkakoa igotzea.",
      terms5H: "5. Erabiltzailearen edukia",
      terms5P:
        "Igotzen dituzun errezeten, argazkien eta bestelako edukiaren jabetza mantentzen duzu. Zerbitzua emateko soilik edukia gordetzeko, prozesatzeko eta erakusteko lizentzia mugatua ematen diguzu.",
      terms6H: "6. Etxe partekatuak",
      terms6P:
        "Etxe batera batzen bazara, beste kideek planifikatzaile partekatua eta erosketa-zerrenda ikusi eta editatu ahal izango dituzte. Utzi etxea edo ezabatu kontua talde horrekin datuak partekatu nahi ez badituzu.",
      terms7H: "7. Erabilgarritasuna eta aldaketak",
      terms7P:
        "Zerbitzua «dagoen bezala» eskaintzen da. Funtzionalitateak aldatu, aldi baterako eten edo zerbitzua eten, eta termino hauek eguneratu ditzakegu. Aldaketa garrantzitsuak bide arrazoizkoen bidez jakinaraziko dira (adib. Appan edo orrialde honetan).",
      terms8H: "8. Erantzukizunaren mugaketa",
      terms8P:
        "Böl etxeko antolakuntza tresna bat da. Ez du mediku, nutrizio edo elikagaien segurtasun aholkularitza ordezkatzen. Aplikazioaren erabileratik eratorritako kalte zeharkakoen erantzule ez gara, aplikagarria den legeak onartzen duen neurrian.",
      terms9H: "9. Aplikagarria den legea",
      terms9P:
        "Termino hauek Espainiako eta Europako legeria aplikagarriaren arabera arautzen dira. Kontsumo-erreklamazioetarako, zure jurisdikzioan aurreikusitako gatazka-ebazpen mekanismoetara jo dezakezu.",
      terms10H: "10. Harremana",
      terms10P:
        "Termino hauei buruzko kontsultetarako: ireki issue bat proiektuaren GitHub biltegi publikoan edo jarri harremanetan aplikazio-dendako fitxan adierazitako zerbitzuaren arduradunarekin.",

      privacyTitle: "Pribatutasun Politika — Böl",
      privacyH1: "Pribatutasun Politika",
      privacy1H: "1. Tratamenduaren arduraduna",
      privacy1P:
        "Böl-ekin lotutako datu pertsonalen tratamenduaren arduraduna proiektuaren titularra da, GitHub biltegiaren edo aplikazio-dendako fitxaren bidez harremanetan jar daitekeena.",
      privacy2H: "2. Biltzen ditugun datuak",
      privacy2L1:
        "<strong>Kontua:</strong> posta elektronikoa, erabiltzaile-izena, autentifikazio-identifikatzaileak (adib. Google edo Apple).",
      privacy2L2: "<strong>Profila:</strong> avatarra (aukerakoa).",
      privacy2L3:
        "<strong>Edukia:</strong> errezeta, osagaiak, asteplanifikatzailea, erosketa-zerrendak.",
      privacy2L4:
        "<strong>Etxe partekatua:</strong> kidetasuna eta etxearen izena sortu edo batzen bazara.",
      privacy2L5:
        "<strong>Teknikoak:</strong> erabilera-datu agregatuak (Firebase Analytics), erroreak (Sentry) eta diagnostiko-erregistroak.",
      privacy3H: "3. Helburua eta oinarri juridikoa",
      privacy3L1: "Zerbitzua ematea (kontratuaren betearazpena / interes legitimoa).",
      privacy3L2: "Autentifikazioa eta kontuaren segurtasuna (interes legitimoa).",
      privacy3L3:
        "Produktuaren hobekuntza eta egonkortasuna (interes legitimoa / baimena aplikagarria denean).",
      privacy3L4: "Legezko betebeharrak betetzea.",
      privacy4H: "4. Tratamendu-eragileak eta transferentziak",
      privacy4P: "Gure izenean datuak tratatzen dituzten hornitzaileak erabiltzen ditugu:",
      privacy4L1:
        "<strong>Supabase</strong> — datu-basea, autentifikazioa eta biltegiratzea (EB, eu-west-1 eskualdea).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — erabilera-analitika.",
      privacy4L3: "<strong>Sentry</strong> — errore-monitorizazioa.",
      privacy4L4:
        "<strong>Google / Apple</strong> — OAuth saio-hasiera aukeratzen duzunean.",
      privacy4P2:
        "Hornitzaile hauek kontratu-klausula estandarren edo RGPD-ak aitortutako bestelako bermeen menpe egon daitezke.",
      privacy5H: "5. Gordetzea",
      privacy5P:
        "Zure datuak kontua aktibo den bitartean gordetzen ditugu. Kontua ezabatu ondoren, datu pertsonalak epe arrazoizko batean ezabatzen edo anonimizatzen ditugu, legezko gordetze-betebeharrik ez badago.",
      privacy6H: "6. Zure eskubideak (RGPD)",
      privacy6P: "Eskubidea duzu:",
      privacy6L1: "Zure datuak atzitzeko, zuzentzeko eta ezabatzeko.",
      privacy6L2: "Tratamendu jakin batzuk mugatzeko edo haien aurka egiteko.",
      privacy6L3: "Eman dizkiguzun datuen eramangarritasunerako.",
      privacy6L4: "Tratamendua baimenean oinarritzen denean baimena kentzeko.",
      privacy6L5: "AEPDn edo beste agintari eskudun batean erreklamazioa aurkezteko.",
      privacy6P2:
        "<strong>Kontua ezabatzea</strong> zuzenean Appetik egin dezakezu: Profila → Kontua ezabatu. Ekintza hau atzeraezina da eta zure profila, errezeta eta lotutako datuak gure sistemetatik kentzen ditu.",
      privacy7H: "7. Adingabeak",
      privacy7P:
        "Zerbitzua ez dago 16 urtetik beherakoentzat zuzenduta. Gurasoen baimen egiaztagarririk gabeko adingabe baten kontua detektatzen badugu, ezaba dezakegu.",
      privacy8H: "8. Segurtasuna",
      privacy8P:
        "Neurri tekniko eta antolakuntza arrazoizkoak aplikatzen ditugu (igarobidean enkriptatzea, sarbide-kontrola, gailuan saioaren biltegiratze segurua). Sistema bat ere ez da %100 segurua.",
      privacy9H: "9. Aldaketak",
      privacy9P:
        "Politika hau egunera dezakegu. «Azken eguneratzea» datak indarrean dagoen bertsioa islatuko du. Aldaketa garrantzitsuen ondoren jarraitutako erabilerak onarpena dakar legeak baimentzen duenean.",
      privacy10H: "10. Harremana",
      privacy10P:
        "Zure eskubideak baliatzeko edo pribatutasun-kontsultetarako, erabili kontua ezabatzea Appan edo jarri harremanetan proiektuaren GitHub biltegiaren bidez.",
    },

    gl: {
      brand: "Böl",
      navTerms: "Termos e Condicións",
      navPrivacy: "Política de Privacidade",
      langLabel: "Idioma",
      footer: "© 2026 Böl",
      updated: "Última actualización: xuño de 2026",

      indexTitle: "Böl — Información legal",
      indexH1: "Información legal",
      indexIntro:
        "Böl é unha aplicación para planificar comidas semanais e xerar listas da compra. Aquí atoparás os documentos legais aplicables ao uso do servizo.",
      indexTermsCardTitle: "Termos e Condicións",
      indexTermsCardDesc: "Condicións de uso da aplicación e do servizo.",
      indexPrivacyCardTitle: "Política de Privacidade",
      indexPrivacyCardDesc:
        "Como tratamos os teus datos persoais conforme ao RGPD e os teus dereitos, incluída a supresión da conta.",

      termsTitle: "Termos e Condicións — Böl",
      termsH1: "Termos e Condicións",
      terms1H: "1. Aceptación",
      terms1P:
        "Ao rexistrarte ou utilizar Böl («a App»), aceptas estes Termos e Condicións. Se non estás de acordo, non uses o servizo.",
      terms2H: "2. Descrición do servizo",
      terms2P:
        "Böl permite xestionar un receitario persoal, planificar comidas semanais, xerar listas da compra e, opcionalmente, compartir un fogar con outros usuarios para colaborar no planificador e na lista.",
      terms3H: "3. Conta de usuario",
      terms3L1: "Debes proporcionar información veraz ao rexistrarte.",
      terms3L2: "Es responsable de manter a confidencialidade das túas credenciais.",
      terms3L3: "Debes notificar calquera uso non autorizado da túa conta.",
      terms3L4:
        "Podes eliminar a túa conta en calquera momento desde a App (ver Política de Privacidade).",
      terms4H: "4. Uso aceptable",
      terms4P: "Comprométeste a non:",
      terms4L1: "Usar a App con fins ilícitos ou que vulneren dereitos de terceiros.",
      terms4L2: "Intentar acceder sen autorización a sistemas, datos ou contas alleas.",
      terms4L3: "Interferir no funcionamento do servizo ou sobrecargar a infraestrutura.",
      terms4L4: "Subir contido ofensivo, ilegal ou que infrinxa propiedade intelectual.",
      terms5H: "5. Contido do usuario",
      terms5P:
        "Conservas a titularidade das receitas, fotos e demais contido que subas. Concédesnos unha licenza limitada para almacenar, procesar e amosar ese contido unicamente co fin de prestar o servizo.",
      terms6H: "6. Fogares compartidos",
      terms6P:
        "Se te unes a un fogar, os demais membros poderán ver e editar o planificador e a lista da compra compartidos. Abandona o fogar ou elimina a túa conta se xa non desexas compartir datos con ese grupo.",
      terms7H: "7. Dispoñibilidade e cambios",
      terms7P:
        "O servizo ofrécese «tal cal». Podemos modificar funcionalidades, suspender temporalmente ou interromper o servizo, e actualizar estes termos. Os cambios relevantes comunicaranse por medios razoables (p. ex. na App ou nesta páxina).",
      terms8H: "8. Limitación de responsabilidade",
      terms8P:
        "Böl é unha ferramenta de organización doméstica. Non substitúe asesoramento médico, nutricional ou de seguridade alimentaria. Non nos facemos responsables de danos indirectos derivados do uso da App na medida permitida pola lei aplicable.",
      terms9H: "9. Lei aplicable",
      terms9P:
        "Estes termos réxense pola lexislación española e europea aplicable. Para reclamacións de consumo podes acudir aos mecanismos de resolución de conflitos previstos na túa xurisdición.",
      terms10H: "10. Contacto",
      terms10P:
        "Para consultas sobre estes termos: abre un issue no repositorio público do proxecto en GitHub ou contacta co responsable do servizo indicado na ficha da tenda de aplicacións.",

      privacyTitle: "Política de Privacidade — Böl",
      privacyH1: "Política de Privacidade",
      privacy1H: "1. Responsable do tratamento",
      privacy1P:
        "O responsable do tratamento dos datos persoais asociados a Böl é o titular do proxecto, contactable a través do repositorio en GitHub ou a ficha da tenda de aplicacións.",
      privacy2H: "2. Datos que recollemos",
      privacy2L1:
        "<strong>Conta:</strong> correo electrónico, nome de usuario, identificadores de autenticación (p. ex. Google ou Apple).",
      privacy2L2: "<strong>Perfil:</strong> avatar (opcional).",
      privacy2L3:
        "<strong>Contido:</strong> receitas, ingredientes, planificador semanal, listas da compra.",
      privacy2L4:
        "<strong>Fogar compartido:</strong> membresía e nome do fogar se decides crealo ou unirte.",
      privacy2L5:
        "<strong>Técnicos:</strong> datos de uso agregados (Firebase Analytics), erros (Sentry) e rexistros de diagnóstico.",
      privacy3H: "3. Finalidade e base legal",
      privacy3L1: "Prestación do servizo (execución do contrato / interese lexítimo).",
      privacy3L2: "Autenticación e seguridade da conta (interese lexítimo).",
      privacy3L3:
        "Mellora do produto e estabilidade (interese lexítimo / consentimento cando aplique).",
      privacy3L4: "Cumprimento de obrigas legais.",
      privacy4H: "4. Encargados e transferencias",
      privacy4P: "Utilizamos provedores que tratan datos no noso nome:",
      privacy4L1:
        "<strong>Supabase</strong> — base de datos, autenticación e almacenamento (UE, rexión eu-west-1).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — analítica de uso.",
      privacy4L3: "<strong>Sentry</strong> — monitorización de erros.",
      privacy4L4:
        "<strong>Google / Apple</strong> — inicio de sesión OAuth cando o elixes.",
      privacy4P2:
        "Estes provedores poden estar suxeitos a cláusulas contractuais tipo ou outras garantías recoñecidas polo RGPD.",
      privacy5H: "5. Conservación",
      privacy5P:
        "Conservamos os teus datos mentres manteñas unha conta activa. Tras a eliminación da conta, borramos ou anonimizamos os datos persoais nun prazo razoable, salvo obriga legal de conservación.",
      privacy6H: "6. Os teus dereitos (RGPD)",
      privacy6P: "Tes dereito a:",
      privacy6L1: "Acceder, rectificar e suprimir os teus datos.",
      privacy6L2: "Limitar ou opoñerte a determinados tratamentos.",
      privacy6L3: "Portabilidade dos datos que nos facilitases.",
      privacy6L4: "Retirar o consentimento cando o tratamento se basee nel.",
      privacy6L5: "Presentar reclamación ante a AEPD ou outra autoridade competente.",
      privacy6P2:
        "Podes exercer a <strong>supresión da conta</strong> directamente na App: Perfil → Eliminar conta. Esta acción é irreversible e elimina o teu perfil, receitas e datos asociados nos nosos sistemas.",
      privacy7H: "7. Menores",
      privacy7P:
        "O servizo non está dirixido a menores de 16 anos. Se detectamos unha conta dun menor sen consentimento parental verificable, poderemos eliminala.",
      privacy8H: "8. Seguridade",
      privacy8P:
        "Aplicamos medidas técnicas e organizativas razoables (cifrado en tránsito, control de acceso, almacenamento seguro de sesión no dispositivo). Ningún sistema é 100 % seguro.",
      privacy9H: "9. Cambios",
      privacy9P:
        "Podemos actualizar esta política. A data de «última actualización» reflectirá a versión vixente. O uso continuado tras cambios relevantes implica a súa aceptación cando a lei o permita.",
      privacy10H: "10. Contacto",
      privacy10P:
        "Para exercer os teus dereitos ou consultas de privacidade, utiliza a eliminación de conta na App ou contacta a través do repositorio do proxecto en GitHub.",
    },

    pt: {
      brand: "Böl",
      navTerms: "Termos e Condições",
      navPrivacy: "Política de Privacidade",
      langLabel: "Idioma",
      footer: "© 2026 Böl",
      updated: "Última atualização: junho de 2026",

      indexTitle: "Böl — Informação legal",
      indexH1: "Informação legal",
      indexIntro:
        "Böl é uma aplicação para planear refeições semanais e gerar listas de compras. Aqui encontrará os documentos legais aplicáveis à utilização do serviço.",
      indexTermsCardTitle: "Termos e Condições",
      indexTermsCardDesc: "Condições de utilização da aplicação e do serviço.",
      indexPrivacyCardTitle: "Política de Privacidade",
      indexPrivacyCardDesc:
        "Como tratamos os seus dados pessoais ao abrigo do RGPD e os seus direitos, incluindo a eliminação da conta.",

      termsTitle: "Termos e Condições — Böl",
      termsH1: "Termos e Condições",
      terms1H: "1. Aceitação",
      terms1P:
        "Ao registar-se ou utilizar a Böl («a App»), aceita estes Termos e Condições. Se não concordar, não utilize o serviço.",
      terms2H: "2. Descrição do serviço",
      terms2P:
        "A Böl permite gerir um livro de receitas pessoal, planear refeições semanais, gerar listas de compras e, opcionalmente, partilhar uma casa com outros utilizadores para colaborar no planeador e na lista.",
      terms3H: "3. Conta de utilizador",
      terms3L1: "Deve fornecer informação verdadeira ao registar-se.",
      terms3L2: "É responsável por manter a confidencialidade das suas credenciais.",
      terms3L3: "Deve notificar qualquer utilização não autorizada da sua conta.",
      terms3L4:
        "Pode eliminar a sua conta a qualquer momento na App (ver Política de Privacidade).",
      terms4H: "4. Utilização aceitável",
      terms4P: "Compromete-se a não:",
      terms4L1: "Utilizar a App para fins ilícitos ou que violem direitos de terceiros.",
      terms4L2: "Tentar aceder sem autorização a sistemas, dados ou contas alheias.",
      terms4L3: "Interferir no funcionamento do serviço ou sobrecarregar a infraestrutura.",
      terms4L4: "Carregar conteúdo ofensivo, ilegal ou que infrinja propriedade intelectual.",
      terms5H: "5. Conteúdo do utilizador",
      terms5P:
        "Mantém a titularidade das receitas, fotos e outro conteúdo que carregar. Concede-nos uma licença limitada para armazenar, processar e apresentar esse conteúdo apenas para prestar o serviço.",
      terms6H: "6. Casas partilhadas",
      terms6P:
        "Se aderir a uma casa, os outros membros poderão ver e editar o planeador e a lista de compras partilhados. Saia da casa ou elimine a conta se já não desejar partilhar dados com esse grupo.",
      terms7H: "7. Disponibilidade e alterações",
      terms7P:
        "O serviço é prestado «tal como está». Podemos alterar funcionalidades, suspender temporariamente ou interromper o serviço, e atualizar estes termos. Alterações relevantes serão comunicadas por meios razoáveis (p. ex. na App ou nesta página).",
      terms8H: "8. Limitação de responsabilidade",
      terms8P:
        "A Böl é uma ferramenta de organização doméstica. Não substitui aconselhamento médico, nutricional ou de segurança alimentar. Não nos responsabilizamos por danos indiretos decorrentes da utilização da App na medida permitida pela lei aplicável.",
      terms9H: "9. Lei aplicável",
      terms9P:
        "Estes termos regem-se pela legislação espanhola e europeia aplicável. Para reclamações de consumo pode recorrer aos mecanismos de resolução de conflitos previstos na sua jurisdição.",
      terms10H: "10. Contacto",
      terms10P:
        "Para questões sobre estes termos: abra um issue no repositório público do projeto no GitHub ou contacte o responsável pelo serviço indicado na ficha da loja de aplicações.",

      privacyTitle: "Política de Privacidade — Böl",
      privacyH1: "Política de Privacidade",
      privacy1H: "1. Responsável pelo tratamento",
      privacy1P:
        "O responsável pelo tratamento dos dados pessoais associados à Böl é o titular do projeto, contactável através do repositório no GitHub ou da ficha da loja de aplicações.",
      privacy2H: "2. Dados que recolhemos",
      privacy2L1:
        "<strong>Conta:</strong> correio eletrónico, nome de utilizador, identificadores de autenticação (p. ex. Google ou Apple).",
      privacy2L2: "<strong>Perfil:</strong> avatar (opcional).",
      privacy2L3:
        "<strong>Conteúdo:</strong> receitas, ingredientes, planeador semanal, listas de compras.",
      privacy2L4:
        "<strong>Casa partilhada:</strong> adesão e nome da casa se a criar ou a ela aderir.",
      privacy2L5:
        "<strong>Técnicos:</strong> dados de utilização agregados (Firebase Analytics), erros (Sentry) e registos de diagnóstico.",
      privacy3H: "3. Finalidade e base legal",
      privacy3L1: "Prestação do serviço (execução do contrato / interesse legítimo).",
      privacy3L2: "Autenticação e segurança da conta (interesse legítimo).",
      privacy3L3:
        "Melhoria do produto e estabilidade (interesse legítimo / consentimento quando aplicável).",
      privacy3L4: "Cumprimento de obrigações legais.",
      privacy4H: "4. Subcontratantes e transferências",
      privacy4P: "Utilizamos fornecedores que tratam dados em nosso nome:",
      privacy4L1:
        "<strong>Supabase</strong> — base de dados, autenticação e armazenamento (UE, região eu-west-1).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — análise de utilização.",
      privacy4L3: "<strong>Sentry</strong> — monitorização de erros.",
      privacy4L4:
        "<strong>Google / Apple</strong> — início de sessão OAuth quando o escolher.",
      privacy4P2:
        "Estes fornecedores podem estar sujeitos a cláusulas contratuais-tipo ou outras salvaguardas reconhecidas pelo RGPD.",
      privacy5H: "5. Conservação",
      privacy5P:
        "Conservamos os seus dados enquanto mantiver uma conta ativa. Após a eliminação da conta, apagamos ou anonimizamos os dados pessoais num prazo razoável, salvo obrigação legal de conservação.",
      privacy6H: "6. Os seus direitos (RGPD)",
      privacy6P: "Tem o direito de:",
      privacy6L1: "Aceder, retificar e apagar os seus dados.",
      privacy6L2: "Limitar ou opor-se a determinados tratamentos.",
      privacy6L3: "Portabilidade dos dados que nos tenha fornecido.",
      privacy6L4: "Retirar o consentimento quando o tratamento se basear nele.",
      privacy6L5: "Apresentar reclamação junto da AEPD ou de outra autoridade competente.",
      privacy6P2:
        "Pode exercer a <strong>eliminação da conta</strong> diretamente na App: Perfil → Eliminar conta. Esta ação é irreversível e remove o seu perfil, receitas e dados associados dos nossos sistemas.",
      privacy7H: "7. Menores",
      privacy7P:
        "O serviço não se destina a menores de 16 anos. Se detetarmos uma conta de um menor sem consentimento parental verificável, poderemos eliminá-la.",
      privacy8H: "8. Segurança",
      privacy8P:
        "Aplicamos medidas técnicas e organizativas razoáveis (encriptação em trânsito, controlo de acesso, armazenamento seguro de sessão no dispositivo). Nenhum sistema é 100% seguro.",
      privacy9H: "9. Alterações",
      privacy9P:
        "Podemos atualizar esta política. A data de «última atualização» refletirá a versão vigente. A utilização continuada após alterações relevantes implica a sua aceitação quando a lei o permitir.",
      privacy10H: "10. Contacto",
      privacy10P:
        "Para exercer os seus direitos ou questões de privacidade, utilize a eliminação de conta na App ou contacte através do repositório do projeto no GitHub.",
    },

    it: {
      brand: "Böl",
      navTerms: "Termini e Condizioni",
      navPrivacy: "Informativa sulla Privacy",
      langLabel: "Lingua",
      footer: "© 2026 Böl",
      updated: "Ultimo aggiornamento: giugno 2026",

      indexTitle: "Böl — Informazioni legali",
      indexH1: "Informazioni legali",
      indexIntro:
        "Böl è un’app per pianificare i pasti settimanali e generare liste della spesa. Qui trovi i documenti legali applicabili all’uso del servizio.",
      indexTermsCardTitle: "Termini e Condizioni",
      indexTermsCardDesc: "Condizioni d’uso dell’applicazione e del servizio.",
      indexPrivacyCardTitle: "Informativa sulla Privacy",
      indexPrivacyCardDesc:
        "Come trattiamo i tuoi dati personali ai sensi del GDPR e i tuoi diritti, inclusa la cancellazione dell’account.",

      termsTitle: "Termini e Condizioni — Böl",
      termsH1: "Termini e Condizioni",
      terms1H: "1. Accettazione",
      terms1P:
        "Registrandoti o utilizzando Böl («l’App»), accetti questi Termini e Condizioni. Se non sei d’accordo, non usare il servizio.",
      terms2H: "2. Descrizione del servizio",
      terms2P:
        "Böl consente di gestire un ricettario personale, pianificare i pasti settimanali, generare liste della spesa e, opzionalmente, condividere una casa con altri utenti per collaborare sul pianificatore e sulla lista.",
      terms3H: "3. Account utente",
      terms3L1: "Devi fornire informazioni veritiere in fase di registrazione.",
      terms3L2: "Sei responsabile di mantenere riservate le tue credenziali.",
      terms3L3: "Devi segnalare qualsiasi uso non autorizzato del tuo account.",
      terms3L4:
        "Puoi eliminare il tuo account in qualsiasi momento dall’App (vedi l’Informativa sulla Privacy).",
      terms4H: "4. Uso accettabile",
      terms4P: "Ti impegni a non:",
      terms4L1: "Usare l’App per scopi illeciti o che violino diritti di terzi.",
      terms4L2: "Tentare di accedere senza autorizzazione a sistemi, dati o account altrui.",
      terms4L3: "Interferire con il funzionamento del servizio o sovraccaricare l’infrastruttura.",
      terms4L4: "Caricare contenuti offensivi, illegali o che violino la proprietà intellettuale.",
      terms5H: "5. Contenuti dell’utente",
      terms5P:
        "Conservi la titolarità delle ricette, foto e altri contenuti che carichi. Ci concedi una licenza limitata per memorizzare, elaborare e mostrare tali contenuti esclusivamente per erogare il servizio.",
      terms6H: "6. Case condivise",
      terms6P:
        "Se ti unisci a una casa, gli altri membri potranno vedere e modificare il pianificatore e la lista della spesa condivisi. Lascia la casa o elimina l’account se non desideri più condividere dati con quel gruppo.",
      terms7H: "7. Disponibilità e modifiche",
      terms7P:
        "Il servizio è fornito «così com’è». Possiamo modificare le funzionalità, sospendere temporaneamente o interrompere il servizio e aggiornare questi termini. Le modifiche rilevanti saranno comunicate con mezzi ragionevoli (es. nell’App o in questa pagina).",
      terms8H: "8. Limitazione di responsabilità",
      terms8P:
        "Böl è uno strumento di organizzazione domestica. Non sostituisce consulenza medica, nutrizionale o sulla sicurezza alimentare. Non siamo responsabili di danni indiretti derivanti dall’uso dell’App nella misura consentita dalla legge applicabile.",
      terms9H: "9. Legge applicabile",
      terms9P:
        "Questi termini sono regolati dalla legislazione spagnola ed europea applicabile. Per reclami dei consumatori puoi rivolgersi ai meccanismi di risoluzione delle controversie previsti nella tua giurisdizione.",
      terms10H: "10. Contatti",
      terms10P:
        "Per domande su questi termini: apri una issue nel repository pubblico del progetto su GitHub o contatta il responsabile del servizio indicato nella scheda dello store delle app.",

      privacyTitle: "Informativa sulla Privacy — Böl",
      privacyH1: "Informativa sulla Privacy",
      privacy1H: "1. Titolare del trattamento",
      privacy1P:
        "Il titolare del trattamento dei dati personali associati a Böl è il titolare del progetto, contattabile tramite il repository su GitHub o la scheda dello store delle app.",
      privacy2H: "2. Dati che raccogliamo",
      privacy2L1:
        "<strong>Account:</strong> email, nome utente, identificatori di autenticazione (es. Google o Apple).",
      privacy2L2: "<strong>Profilo:</strong> avatar (opzionale).",
      privacy2L3:
        "<strong>Contenuti:</strong> ricette, ingredienti, pianificatore settimanale, liste della spesa.",
      privacy2L4:
        "<strong>Casa condivisa:</strong> adesione e nome della casa se la crei o ti unisci.",
      privacy2L5:
        "<strong>Tecnici:</strong> dati di utilizzo aggregati (Firebase Analytics), errori (Sentry) e log diagnostici.",
      privacy3H: "3. Finalità e base giuridica",
      privacy3L1: "Erogazione del servizio (esecuzione del contratto / interesse legittimo).",
      privacy3L2: "Autenticazione e sicurezza dell’account (interesse legittimo).",
      privacy3L3:
        "Miglioramento del prodotto e stabilità (interesse legittimo / consenso ove applicabile).",
      privacy3L4: "Adempimento di obblighi di legge.",
      privacy4H: "4. Responsabili e trasferimenti",
      privacy4P: "Utilizziamo fornitori che trattano dati per nostro conto:",
      privacy4L1:
        "<strong>Supabase</strong> — database, autenticazione e storage (UE, regione eu-west-1).",
      privacy4L2: "<strong>Google Firebase Analytics</strong> — analitiche di utilizzo.",
      privacy4L3: "<strong>Sentry</strong> — monitoraggio errori.",
      privacy4L4:
        "<strong>Google / Apple</strong> — accesso OAuth quando lo scegli.",
      privacy4P2:
        "Questi fornitori possono essere soggetti a clausole contrattuali tipo o ad altre garanzie riconosciute dal GDPR.",
      privacy5H: "5. Conservazione",
      privacy5P:
        "Conserviamo i tuoi dati finché mantieni un account attivo. Dopo l’eliminazione dell’account, cancelliamo o anonimizziamo i dati personali entro un termine ragionevole, salvo obblighi legali di conservazione.",
      privacy6H: "6. I tuoi diritti (GDPR)",
      privacy6P: "Hai il diritto di:",
      privacy6L1: "Accedere, rettificare e cancellare i tuoi dati.",
      privacy6L2: "Limitare o opporti a determinati trattamenti.",
      privacy6L3: "Portabilità dei dati che ci hai fornito.",
      privacy6L4: "Revocare il consenso quando il trattamento si basa su di esso.",
      privacy6L5: "Presentare reclamo all’AEPD o a un’altra autorità competente.",
      privacy6P2:
        "Puoi esercitare la <strong>cancellazione dell’account</strong> direttamente nell’App: Profilo → Elimina account. L’azione è irreversibile e rimuove profilo, ricette e dati associati dai nostri sistemi.",
      privacy7H: "7. Minori",
      privacy7P:
        "Il servizio non è rivolto a minori di 16 anni. Se rileviamo un account di un minore senza consenso genitoriale verificabile, potremo eliminarlo.",
      privacy8H: "8. Sicurezza",
      privacy8P:
        "Applichiamo misure tecniche e organizzative ragionevoli (cifratura in transito, controllo degli accessi, archiviazione sicura della sessione sul dispositivo). Nessun sistema è sicuro al 100%.",
      privacy9H: "9. Modifiche",
      privacy9P:
        "Possiamo aggiornare questa informativa. La data di «ultimo aggiornamento» rifletterà la versione vigente. L’uso continuato dopo modifiche rilevanti ne implica l’accettazione quando la legge lo consente.",
      privacy10H: "10. Contatti",
      privacy10P:
        "Per esercitare i tuoi diritti o per domande sulla privacy, usa l’eliminazione dell’account nell’App o contattaci tramite il repository del progetto su GitHub.",
    },
  };

  function detectLang() {
    try {
      var stored = localStorage.getItem(STORAGE_KEY);
      if (stored && T[stored]) return stored;
    } catch (_) {}
    var nav = (navigator.language || navigator.userLanguage || "es").toLowerCase();
    var code = nav.split("-")[0];
    if (T[code]) return code;
    return "es";
  }

  function apply(lang) {
    var dict = T[lang] || T.es;
    document.documentElement.lang = lang;

    document.querySelectorAll("[data-i18n]").forEach(function (el) {
      var key = el.getAttribute("data-i18n");
      if (dict[key] != null) el.textContent = dict[key];
    });

    document.querySelectorAll("[data-i18n-html]").forEach(function (el) {
      var key = el.getAttribute("data-i18n-html");
      if (dict[key] != null) el.innerHTML = dict[key];
    });

    document.querySelectorAll("[data-i18n-title]").forEach(function (el) {
      var key = el.getAttribute("data-i18n-title");
      if (dict[key] != null) document.title = dict[key];
    });

    var select = document.getElementById("lang-select");
    if (select) select.value = lang;

    try {
      localStorage.setItem(STORAGE_KEY, lang);
    } catch (_) {}
  }

  function buildSelector() {
    var host = document.getElementById("lang-switcher");
    if (!host) return;

    var label = document.createElement("label");
    label.setAttribute("for", "lang-select");
    label.setAttribute("data-i18n", "langLabel");
    label.textContent = "Idioma";

    var select = document.createElement("select");
    select.id = "lang-select";
    select.setAttribute("aria-label", "Language");
    LANGS.forEach(function (lang) {
      var opt = document.createElement("option");
      opt.value = lang.code;
      opt.textContent = lang.label;
      select.appendChild(opt);
    });
    select.addEventListener("change", function () {
      apply(select.value);
    });

    host.appendChild(label);
    host.appendChild(select);
  }

  document.addEventListener("DOMContentLoaded", function () {
    buildSelector();
    apply(detectLang());
  });
})();
