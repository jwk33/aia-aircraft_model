# AIA Aircraft Model

## General
Code is used to size aircraft based on mission requirements with calculations for:
1. Weight
2. Drag
3. Fuel Burn

Weight calculations are made using correlations and tank weight calculations are made using the AIA tank weight model.

## Flowchart

### Basic Design Loop

```mermaid
flowchart LR
    %% A: Aircraft Input
    %% B: Manual Inputs
    %% C: Design Mission
    %% D: Dimension
    %% E: Initial Guess
    %% F: Weight
    %% G: Aero
    %% H: Engine
    %% I: FuelBurn
    %% J: MTOW check
    %% K: FuelTank
    %% Z: Output Aircraft

    B[Manual Inputs \n _Optional_] -."Eta \n Wing Loading \n etc."....-> A{{Aircraft Input}}
    
    C[Design Mission] ---> A
    C --"Cabin \n Layout"---> D[Dimension]
    D ---> A

    subgraph a[MAIN DESIGN LOOP]
    E[Initial Guess] -.-> ANALYSIS

    A --> ANALYSIS
    subgraph ANALYSIS
        G[Aero] --> H[Engine]
        H --> I[FuelBurn]
        I --> F[Weight]
    end    

    ANALYSIS --"Aircraft \n Iteration"--> J{MTOW Converged?}
    J ----> |No|ANALYSIS


    
    

    
    end


    Z{{Designed Aircraft}}
    

    J --> |Yes|Z
    
```
### Hydrogen Aircraft Design Flowchart
```mermaid
flowchart LR
    %% A: Aircraft Input
    %% B: Manual Inputs
    %% C: Design Mission
    %% D: Dimension
    %% E: Initial Guess
    %% F: Weight
    %% G: Aero
    %% H: Engine
    %% I: FuelBurn
    %% J: MTOW check
    %% K: FuelTank
    %% Z: Output Aircraft

    B[Manual Inputs \n _Optional_] -."Eta \n Wing Loading \n etc."....-> A{{Aircraft Input}}
    
    C[Design Mission] ---> A
    C --"Cabin \n Layout"--> D[Dimension]
    D ----> A

    D --"Tank \n Dimensions"--> t
    subgraph t[HYDROGEN TANK]
        K[Structural] --> L[Insulation]

    end
    t --> A

    subgraph a[MAIN DESIGN LOOP]
    E[Initial Guess] -.-> ANALYSIS

    A --> ANALYSIS
    subgraph ANALYSIS
        G[Aero] --> H[Engine]
        H --> I[FuelBurn]
        I --> F[Weight]
    end    

    ANALYSIS --"Aircraft \n Iteration"--> J{MTOW Converged?}
    J ----> |No|ANALYSIS


    
    

    
    end


    Z{{Designed Aircraft}}
    

    J --> |Yes|Z
```
### Operation Loop
```mermaid
flowchart LR
    %% A: Operation Mission
    %% B: Initial Mass Guess
    %% C: Design Mission
    %% D: Dimension
    %% E: Initial Aircraft
    %% F: Weight
    %% H: Engine
    %% K: FuelTank
    %% Z: Output Aircraft

    Z{{Designed Aircraft}}
    A[Operation Mission]

    Z --> I
    A --> I
    subgraph loop1[OPERATION LOOP]
        C[Initial Mass Guess] -.-> ANALYSIS
        subgraph ANALYSIS
            I[FuelBurn] --> F[Weight]
        end 

        ANALYSIS --> D{TOW \n Converged?}
        D -->|No|ANALYSIS

      
    end
    
    D ---->|Yes| X
    X{{Operated Aircraft}}

```
## Class Diagram
```mermaid
classDiagram
    direction TB
        Mission "*" --|> "1" Aircraft
        Dimension --|> Aircraft
        Dimension --|> FuelTank

        Aircraft <|-- FuelBurn
        Aircraft <|-- Aero
        Aircraft <|-- Engine
        Aircraft <|-- Weight
        Aircraft <|-- FuelTank

        Aero <|-- Technology
        Engine <|-- Technology
        Weight <|-- Technology
        

        FuelTank <|-- Fuel
        FuelTank "1" <|-- "2" Material

    class Aircraft{
        +Int        year
        +String     optimism
        +Fuel       fuel
        +Aero       aero
        +Engine     engine
        +Weight     weight
        +FuelBurn   fuelBurn
        +Mission    design_mission
        +Mission    operation_mission
        +finalise()
        +operate(operation_mission)
        +max_range(operation_mission)
    }
    class Mission{
        +range
        +Max_Passengers
        +Passengers
        +Cargo
        +Max_Cargo
        +Load_Factor

        +Cruise_Mach
        +Cruise_Altitude

        +update()
    }
    class Dimension{
        +Float cabin_length
        +Float cabin_width
        +Float inline_tank_length
        +Float inline_tank_diameter
        +Float underfloor_tank_length
        +Float underfloor_tank_diameter
        +finalise()
    }
    class FuelBurn{
        +m_fuel_total
        +m_fuel_mission
        +m_fuel_reserve
        +m_fuel_climb
        +m_fuel_cruise
        +m_fuel_descent
        +FuelBurn_Iteration()
        +operate(operation_mission)
    }
    class Aero{
        +LoD
        +C_L
        +C_D
        +wing_area
        +wing_sweep
        +wing_taper
        +wing_thickness
        +wing_loading

        +Aero_Iteration()
        -calculate_mass()
    }
    class Engine{
        +eta_ov
        +eta_eng
        +eta_prop
        +thrust_total
        +number_engines
        +bpr
        +m_engine

        +Engine_Iteration()
        -calculate_mass()
    }
    class Weight{
        +MTOW
        +MZFW
        +OEW
        +Max_Fuel
        +Max_Payload
        +Fuel
        +Payload
        +m_wing
        +m_fuselage
        +m_LG
        +m_tail
        +m_engine
        +m_fuelsys
        +m_furnishings
        +m_op_items
        +m_MZF_delta

        +Weight_Iteration()
        +operate(operation_mission)
        -finalise()
        
    }
    class FuelTank{
        +fuel
        +Ext_diam
        +Ext_length
        +Int_diam
        +Ext_length
        +fuel_volume
        +fuel_mass
        +empty_mass
        +finalise()
    }
    class Fuel{
        +String fuelName
        +Float lhv
        +Float density
        +Bool useTankModel
    }

    class Material{
        +String materialName
        +Float Yield_strength
        +Float density
        +Float thermal_conducitivity
    }

    class Technology{
        +Year
        +Optimism
        
        +improve_LoD(aero)
        +improve_eta(engine)
        +improve_oew(weight)

    }
```
