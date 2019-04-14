
function GetCargoType(category) {
    local cargo_list = AICargoList();

    cargo_list.Valuate(AICargo.HasCargoClass, category);
    cargo_list.KeepValue(1);

    local cargo = cargo_list.Begin();

    if (AICargo.IsValidCargo(cargo)) {
        return cargo;
    } else {
        return null;
    }
}

function GetBestEngine(engine_type, cargo, cash) {
    local engine_list = AIEngineList(engine_type);

    engine_list.Valuate(AIEngine.GetPrice);
    engine_list.KeepBelowValue(cash);

    engine_list.Valuate(AIEngine.GetCargoType);
    engine_list.KeepValue(cargo);

    engine_list.Valuate(AIEngine.GetCapacity);
    engine_list.KeepTop(1);

    local engine = engine_list.Begin();

    if (AIEngine.IsValidEngine(engine)) {
        return engine;
    } else {
        return null;
    }
}
