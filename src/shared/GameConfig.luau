--!strict
-- Fonte de verdade para valores de gameplay compartilhados.
local GameConfig = {
    VERSION = "0.2.4",
    PROJECT_PHASE = 2,
    STAGES = {
        { minimum = 0, name = "Larva voadora" },
        { minimum = 3, name = "Pernilongo" },
        { minimum = 7, name = "Caçador noturno" },
        { minimum = 12, name = "Vampiro alado" },
        { minimum = 18, name = "Mosquito de laboratório" },
        { minimum = 25, name = "Praga dos pântanos" },
        { minimum = 35, name = "Terror da madrugada" },
        { minimum = 48, name = "Rei do enxame" },
        { minimum = 65, name = "Sugador ancestral" },
        { minimum = 85, name = "Deus carmesim" },
        { minimum = 100, name = "Pesadelo crepuscular" },
        { minimum = 110, name = "Lorde da praga estelar" },
        { minimum = 120, name = "Soberano do sangue eterno" },
    },
    UPGRADES = {
        wings = { name = "Asas", baseCost = 12, maxLevel = 30 },
        proboscis = { name = "Tromba", baseCost = 15, maxLevel = 30 },
        stomach = { name = "Estômago", baseCost = 20, maxLevel = 30 },
        body = { name = "Corpo", baseCost = 18, maxLevel = 30 },
    },
}
return table.freeze(GameConfig)
