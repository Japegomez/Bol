import 'package:meal_planner/features/recipes/domain/cooking_glossary_entry.dart';

/// Default glossary entries keyed by locale language code.
/// Spanish is the canonical set; other locales provide translated defaults.
const defaultCookingGlossaryByLocale =
    <String, List<CookingGlossaryEntry>>{
  'es': _defaultEs,
  'en': _defaultEn,
  'it': _defaultIt,
};

List<CookingGlossaryEntry> defaultGlossaryForLocale(String languageCode) {
  return defaultCookingGlossaryByLocale[languageCode] ??
      defaultCookingGlossaryByLocale['es']!;
}

/// Backward-compatible export (Spanish defaults).
const defaultCookingGlossaryEntries = _defaultEs;

const _defaultEs = <CookingGlossaryEntry>[
  CookingGlossaryEntry(
    term: 'Ahumar',
    definition:
        'Exponer alimentos al humo, generalmente de madera, para conservarlos '
        'y darles un sabor característico.',
  ),
  CookingGlossaryEntry(
    term: 'Al baño maría',
    definition:
        'Cocinar alimentos colocando el recipiente dentro de otro con agua '
        'caliente o hirviendo, controlando la temperatura.',
  ),
  CookingGlossaryEntry(
    term: 'Al dente',
    definition:
        'Punto de cocción en el que la pasta o arroz están cocidos pero firmes '
        'al morder.',
  ),
  CookingGlossaryEntry(
    term: 'Batir a punto de nieve',
    definition:
        'Montar claras de huevo hasta que formen picos firmes y se mantengan.',
  ),
  CookingGlossaryEntry(
    term: 'Blanquear',
    definition:
        'Hervir brevemente alimentos y enfriarlos rápidamente en agua con hielo '
        'para conservar su color y textura.',
  ),
  CookingGlossaryEntry(
    term: 'Brasear',
    definition:
        'Cocinar a fuego lento con poco líquido en una olla tapada hasta que '
        'el alimento quede tierno.',
  ),
  CookingGlossaryEntry(
    term: 'Brunoise',
    definition:
        'Corte en dados muy pequeños y uniformes, típico en verduras.',
  ),
  CookingGlossaryEntry(
    term: 'Caramelizar',
    definition:
        'Calentar azúcar o alimentos hasta que adquieran color ámbar y un '
        'sabor más intenso.',
  ),
  CookingGlossaryEntry(
    term: 'Clarificar',
    definition:
        'Hacer un líquido (como caldo o mantequilla) transparente eliminando '
        'sus impurezas.',
  ),
  CookingGlossaryEntry(
    term: 'Cocinar al vapor',
    definition:
        'Cocinar alimentos suspendidos sobre agua hirviendo sin contacto '
        'directo con el líquido.',
  ),
  CookingGlossaryEntry(
    term: 'Confitar',
    definition:
        'Cocinar un alimento a baja temperatura en grasa o aceite durante '
        'mucho tiempo para conservarlo.',
  ),
  CookingGlossaryEntry(
    term: 'Deglasar',
    definition:
        'Disolver los restos caramelizados del fondo de una sartén con líquido '
        'caliente (vino, caldo, etc.).',
  ),
  CookingGlossaryEntry(
    term: 'Desglasar',
    definition: 'Sinónimo de deglasar.',
  ),
  CookingGlossaryEntry(
    term: 'Emulsionar',
    definition:
        'Mezclar dos líquidos que normalmente no se combinan (como aceite y '
        'vinagre) hasta formar una mezcla homogénea.',
  ),
  CookingGlossaryEntry(
    term: 'Escalfar',
    definition:
        'Cocinar alimentos en líquido a temperatura justo por debajo del '
        'punto de ebullición.',
  ),
  CookingGlossaryEntry(
    term: 'Estofar',
    definition:
        'Cocinar alimentos a fuego lento en poco líquido, generalmente en '
        'cazuela tapada.',
  ),
  CookingGlossaryEntry(
    term: 'Flambear',
    definition:
        'Rociar un alimento con alcohol y encenderlo brevemente para aportar '
        'sabor sin añadir mucho líquido.',
  ),
  CookingGlossaryEntry(
    term: 'Glasear',
    definition:
        'Cubrir un alimento con una capa brillante, dulce o salada, mediante '
        'cocción o baño.',
  ),
  CookingGlossaryEntry(
    term: 'Gratinar',
    definition:
        'Cocinar en el horno con calor superior intenso hasta formar una capa '
        'dorada y crujiente.',
  ),
  CookingGlossaryEntry(
    term: 'Juliana',
    definition:
        'Corte en tiras finas y alargadas, como palitos.',
  ),
  CookingGlossaryEntry(
    term: 'Marinar',
    definition:
        'Dejar alimentos en un adobo (aceite, ácido, especias) para '
        'ablandarlos y darles sabor.',
  ),
  CookingGlossaryEntry(
    term: 'Pochar',
    definition:
        'Cocinar en líquido a fuego muy suave, sin que hierva con fuerza.',
  ),
  CookingGlossaryEntry(
    term: 'Reducir',
    definition:
        'Hervir un líquido para evaporar agua y concentrar sabores.',
  ),
  CookingGlossaryEntry(
    term: 'Rehogar',
    definition:
        'Cocinar a fuego medio con un poco de grasa, removiendo, hasta que '
        'el alimento esté dorado o tierno.',
  ),
  CookingGlossaryEntry(
    term: 'Saltear',
    definition:
        'Cocinar a fuego alto con poco aceite, moviendo constantemente.',
  ),
  CookingGlossaryEntry(
    term: 'Sofreír',
    definition:
        'Cocinar a fuego medio-bajo con aceite hasta que los ingredientes '
        'estén tiernos y aromáticos.',
  ),
  CookingGlossaryEntry(
    term: 'Termorregular',
    definition:
        'Mantener alimentos a una temperatura constante y precisa, a menudo '
        'con baño maría o circulador.',
  ),
];

const _defaultEn = <CookingGlossaryEntry>[
  CookingGlossaryEntry(
    term: 'Smoke',
    definition:
        'Expose food to smoke, usually from wood, to preserve it and add '
        'characteristic flavor.',
  ),
  CookingGlossaryEntry(
    term: 'Bain-marie',
    definition:
        'Cook food in a container placed inside another with hot or boiling '
        'water to control temperature.',
  ),
  CookingGlossaryEntry(
    term: 'Al dente',
    definition:
        'Doneness where pasta or rice is cooked but still firm to the bite.',
  ),
  CookingGlossaryEntry(
    term: 'Whip to stiff peaks',
    definition:
        'Beat egg whites until they form firm peaks that hold their shape.',
  ),
  CookingGlossaryEntry(
    term: 'Blanch',
    definition:
        'Briefly boil food and quickly cool it in ice water to preserve '
        'color and texture.',
  ),
  CookingGlossaryEntry(
    term: 'Braise',
    definition:
        'Cook slowly with a little liquid in a covered pot until tender.',
  ),
  CookingGlossaryEntry(
    term: 'Brunoise',
    definition: 'Very small, uniform dice cut, typical for vegetables.',
  ),
  CookingGlossaryEntry(
    term: 'Caramelize',
    definition:
        'Heat sugar or food until it turns amber and develops deeper flavor.',
  ),
  CookingGlossaryEntry(
    term: 'Clarify',
    definition:
        'Make a liquid (such as stock or butter) clear by removing impurities.',
  ),
  CookingGlossaryEntry(
    term: 'Steam',
    definition:
        'Cook food suspended over boiling water without direct contact with '
        'the liquid.',
  ),
  CookingGlossaryEntry(
    term: 'Confit',
    definition:
        'Cook food at low temperature in fat or oil for a long time to preserve it.',
  ),
  CookingGlossaryEntry(
    term: 'Deglaze',
    definition:
        'Dissolve caramelized bits from the bottom of a pan with hot liquid '
        '(wine, stock, etc.).',
  ),
  CookingGlossaryEntry(
    term: 'Emulsify',
    definition:
        'Combine two liquids that normally do not mix (like oil and vinegar) '
        'into a homogeneous mixture.',
  ),
  CookingGlossaryEntry(
    term: 'Poach',
    definition:
        'Cook food in liquid just below boiling point.',
  ),
  CookingGlossaryEntry(
    term: 'Stew',
    definition:
        'Cook slowly in a little liquid, usually in a covered pot.',
  ),
  CookingGlossaryEntry(
    term: 'Flambé',
    definition:
        'Pour alcohol over food and briefly ignite it to add flavor without '
        'much extra liquid.',
  ),
  CookingGlossaryEntry(
    term: 'Glaze',
    definition:
        'Cover food with a shiny sweet or savory coating by cooking or basting.',
  ),
  CookingGlossaryEntry(
    term: 'Gratin',
    definition:
        'Bake with intense top heat until a golden, crisp layer forms.',
  ),
  CookingGlossaryEntry(
    term: 'Julienne',
    definition: 'Cut into thin, matchstick-like strips.',
  ),
  CookingGlossaryEntry(
    term: 'Marinate',
    definition:
        'Soak food in a seasoned mixture to tenderize and flavor it.',
  ),
  CookingGlossaryEntry(
    term: 'Simmer',
    definition: 'Cook in liquid over very gentle heat without a rolling boil.',
  ),
  CookingGlossaryEntry(
    term: 'Reduce',
    definition: 'Boil a liquid to evaporate water and concentrate flavors.',
  ),
  CookingGlossaryEntry(
    term: 'Sweat',
    definition:
        'Cook over medium heat with a little fat, stirring, until softened '
        'and aromatic.',
  ),
  CookingGlossaryEntry(
    term: 'Sauté',
    definition: 'Cook over high heat with little oil, stirring constantly.',
  ),
  CookingGlossaryEntry(
    term: 'Sweat (sofrito)',
    definition:
        'Cook over medium-low heat with oil until ingredients are tender and '
        'aromatic.',
  ),
  CookingGlossaryEntry(
    term: 'Sous-vide',
    definition:
        'Hold food at a precise constant temperature, often with a water bath '
        'or circulator.',
  ),
];

const _defaultIt = <CookingGlossaryEntry>[
  CookingGlossaryEntry(
    term: 'Affumicare',
    definition:
        'Esporre gli alimenti al fumo, di solito di legna, per conservarli e '
        'conferire un sapore caratteristico.',
  ),
  CookingGlossaryEntry(
    term: 'Bagnomaria',
    definition:
        'Cuocere gli alimenti mettendo il recipiente dentro un altro con acqua '
        'calda o bollente, per controllare la temperatura.',
  ),
  CookingGlossaryEntry(
    term: 'Al dente',
    definition:
        'Punto di cottura in cui pasta o riso sono cotti ma ancora sodi al morso.',
  ),
  CookingGlossaryEntry(
    term: 'Montare a neve',
    definition:
        'Montare gli albumi finché formano picchi fermi e mantengono la forma.',
  ),
  CookingGlossaryEntry(
    term: 'Scottare',
    definition:
        'Bollire brevemente gli alimenti e raffreddarli subito in acqua e ghiaccio '
        'per conservare colore e texture.',
  ),
  CookingGlossaryEntry(
    term: 'Brasare',
    definition:
        'Cuocere lentamente con poco liquido in una pentola coperta fino a '
        'tenerhezza.',
  ),
  CookingGlossaryEntry(
    term: 'Brunoise',
    definition:
        'Taglio a dadini molto piccoli e uniformi, tipico per le verdure.',
  ),
  CookingGlossaryEntry(
    term: 'Caramellare',
    definition:
        'Riscaldare zucchero o alimenti fino a ottenere un colore ambrato e un '
        'sapore più intenso.',
  ),
  CookingGlossaryEntry(
    term: 'Chiarificare',
    definition:
        'Rendere un liquido (come brodo o burro) trasparente eliminando le '
        'impurità.',
  ),
  CookingGlossaryEntry(
    term: 'Cuocere a vapore',
    definition:
        'Cuocere alimenti sospesi sopra acqua bollente senza contatto diretto '
        'con il liquido.',
  ),
  CookingGlossaryEntry(
    term: 'Confit',
    definition:
        'Cuocere a bassa temperatura nel grasso o nell’olio per lungo tempo '
        'per conservarli.',
  ),
  CookingGlossaryEntry(
    term: 'Sfumare',
    definition:
        'Sciogliere i residui caramellati sul fondo della padella con un liquido '
        'caldo (vino, brodo, ecc.).',
  ),
  CookingGlossaryEntry(
    term: 'Emulsionare',
    definition:
        'Unire due liquidi che di solito non si mescolano (come olio e aceto) '
        'in una miscela omogenea.',
  ),
  CookingGlossaryEntry(
    term: 'Lessare',
    definition:
        'Cuocere alimenti in un liquido appena sotto il punto di ebollizione.',
  ),
  CookingGlossaryEntry(
    term: 'Stufare',
    definition:
        'Cuocere lentamente con poco liquido, di solito in una pentola coperta.',
  ),
  CookingGlossaryEntry(
    term: 'Flambé',
    definition:
        'Versare alcol sul cibo e incendiarlo brevemente per aggiungere sapore '
        'senza troppo liquido extra.',
  ),
  CookingGlossaryEntry(
    term: 'Glassare',
    definition:
        'Coprire gli alimenti con un rivestimento lucido, dolce o salato, '
        'cucinando o spennellando.',
  ),
  CookingGlossaryEntry(
    term: 'Gratín',
    definition:
        'Cuocere in forno con calore intenso in superficie fino a formare uno '
        'strato dorato e croccante.',
  ),
  CookingGlossaryEntry(
    term: 'Julienne',
    definition: 'Tagliare a striscioline sottili come fiammiferi.',
  ),
  CookingGlossaryEntry(
    term: 'Marinare',
    definition:
        'Immergere gli alimenti in una miscela aromatizzata per intenerirli e '
        'insaporirli.',
  ),
  CookingGlossaryEntry(
    term: 'Sobollire',
    definition:
        'Cuocere in liquido a fuoco molto dolce, senza bollitura vivace.',
  ),
  CookingGlossaryEntry(
    term: 'Ridurre',
    definition:
        'Far bollire un liquido per evaporare l’acqua e concentrare i sapori.',
  ),
  CookingGlossaryEntry(
    term: 'Stufare (soffritto)',
    definition:
        'Cuocere a fuoco medio con un po’ di grasso, mescolando, fino a quando '
        'l’alimento è dorato o tenero.',
  ),
  CookingGlossaryEntry(
    term: 'Saltare',
    definition:
        'Cuocere a fuoco alto con poco olio, mescolando continuamente.',
  ),
  CookingGlossaryEntry(
    term: 'Soffriggere',
    definition:
        'Cuocere a fuoco medio-basso con olio fino a quando gli ingredienti '
        'sono teneri e aromatici.',
  ),
  CookingGlossaryEntry(
    term: 'Sous-vide',
    definition:
        'Mantenere gli alimenti a una temperatura costante e precisa, spesso '
        'con bagnomaria o circolatore.',
  ),
];
