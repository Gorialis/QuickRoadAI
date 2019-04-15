
class PlacementOpportunity
{
    tile = null;
    front = null;

    constructor(tile, front) {
        this.tile = tile;
        this.front = front;
    }
}

class TownPlaceabilitySummary
{
    depot_ops = null;
    station_ops = null;

    constructor(town, cargo, station_type)
    {
        AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

        local all_tiles = GetBuildableTiles(town);

        AILog.Info("[" + AITown.GetName(town) + "] All tiles: " + all_tiles.Count());

        // Get tiles that are connected, free roads
        local road_tiles = AIList();
        road_tiles.AddList(all_tiles);
        road_tiles.Valuate(AIRoad.IsRoadTile);
        road_tiles.KeepValue(1);

        AILog.Info("[" + AITown.GetName(town) + " Road] IsRoadTile: " + road_tiles.Count());

        road_tiles.Valuate(AIRoad.IsRoadDepotTile);
        road_tiles.KeepValue(0);

        AILog.Info("[" + AITown.GetName(town) + " Road] IsRoadDepotTile: " + road_tiles.Count());

        road_tiles.Valuate(AIRoad.IsRoadStationTile);
        road_tiles.KeepValue(0);

        AILog.Info("[" + AITown.GetName(town) + " Road] IsRoadStationTile: " + road_tiles.Count());

        road_tiles.Valuate(AIRoad.IsDriveThroughRoadStationTile);
        road_tiles.KeepValue(0);

        AILog.Info("[" + AITown.GetName(town) + "] Road tiles: " + road_tiles.Count());

        // Get station coverage radius
        local station_radius = AIStation.GetCoverageRadius(station_type);

        AILog.Info("[" + AITown.GetName(town) + "] Station coverage: " + station_radius);

        // Find all tiles we can put stations on
        local station_tiles = AIList();
        station_tiles.AddList(road_tiles);
        station_tiles.Valuate(AIRoad.GetNeighbourRoadCount);
        station_tiles.KeepValue(2);

        AILog.Info("[" + AITown.GetName(town) + " Station] 2 neighbors: " + station_tiles.Count());

        station_tiles.Valuate(AITile.GetCargoAcceptance, cargo, 1, 1, station_radius);
        station_tiles.RemoveBelowValue(1);

        AILog.Info("[" + AITown.GetName(town) + " Station] Cargo acceptance: " + station_tiles.Count());

        station_tiles.Valuate(AITile.GetCargoProduction, cargo, 1, 1, station_radius);
        station_tiles.RemoveBelowValue(1);

        AILog.Info("[" + AITown.GetName(town) + " Station] Cargo production: " + station_tiles.Count());

        if (station_tiles.Count() > 8) {
            station_tiles.Valuate(AIBase.RandItem);
            station_tiles.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);
            station_tiles.KeepTop(8);
        }

        // Find all tiles we can put a depot on
        local depot_tiles = AIList();
        depot_tiles.AddList(road_tiles);
        depot_tiles.Valuate(AIRoad.GetNeighbourRoadCount);
        depot_tiles.KeepValue(1);

        // Make depot list
        this.depot_ops = [];

        for (local depot_op_pos = depot_tiles.Begin(); depot_tiles.HasNext(); depot_op_pos = depot_tiles.Next())
        {
            local d_op = GetNeighborPlacementOpportunities(depot_op_pos);

            if (d_op != null)
                this.depot_ops.append(d_op);
        }

        // Make station list
        this.station_ops = [];

        for (local station_op_pos = station_tiles.Begin(); station_tiles.HasNext(); station_op_pos = station_tiles.Next())
        {
            local s_op = GetNeighborPlacementOpportunities(station_op_pos);

            if (s_op != null)
                this.station_ops.append(s_op);
        }

        AILog.Info("[" + AITown.GetName(town) + "] Depot tiles: " + depot_tiles.Count() + ", Station tiles: " + station_tiles.Count());
        AILog.Info("[" + AITown.GetName(town) + "] Depot ops: " + this.depot_ops.len() + ", Station ops: " + this.station_ops.len());
    }
}


function GetBuildableTiles(town)
{
    local town_location = AITown.GetLocation(town);
    local tile_list = AITileList();

    tile_list.AddRectangle(town_location - AIMap.GetTileIndex(15, 15), town_location + AIMap.GetTileIndex(15, 15));

    AILog.Info("[BuildableTiles] All: " + tile_list.Count());

    // Ensure this tile is valid
    tile_list.Valuate(AIMap.IsValidTile);
    tile_list.KeepValue(1);

    AILog.Info("[BuildableTiles] Valid: " + tile_list.Count());

    // Ensure tile is flat (so we can place a station or depot)
    tile_list.Valuate(AITile.GetSlope);
    tile_list.KeepValue(AITile.SLOPE_FLAT);

    AILog.Info("[BuildableTiles] Flat: " + tile_list.Count());

    // Ensure this tile is owned by the town we are trying to appease
    tile_list.Valuate(AITile.GetTownAuthority);
    tile_list.KeepValue(town);

    AILog.Info("[BuildableTiles] Authority: " + tile_list.Count());

    return tile_list;
}


function CheckNeighborRoad(tile, dx, dy) {
    local target = AIMap.GetTileIndex(AIMap.GetTileX(tile) + dx, AIMap.GetTileY(tile) + dy);

    if (AIMap.IsValidTile(target) && AIRoad.IsRoadTile(target))
        return target;

    return null;
}


function GetNeighborPlacementOpportunities(tile) {
    local top = CheckNeighborRoad(tile, 0, -1);

    if (top != null) {
        return PlacementOpportunity(tile, top);
    } else {
        local left = CheckNeighborRoad(tile, -1, 0);

        if (left != null) {
            return PlacementOpportunity(tile, left);
        } else {
            local right = CheckNeighborRoad(tile, 1, 0);

            if (right != null) {
                return PlacementOpportunity(tile, right);
            } else {
                local bottom = CheckNeighborRoad(tile, 0, 1);

                if (bottom != null) {
                    return PlacementOpportunity(tile, bottom);
                } else {
                    return null;
                }
            }
        }
    }
}
