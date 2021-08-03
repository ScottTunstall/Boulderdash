{$ifndef GAMEDEFS_H}
{$define GAMEDEFS_H}


type ExplosionTypes = (ExpDiamonds, ExpNormal, ExpFireflies);

type GameModeTypes = (Demo, RealGame);

type FinalOutCome = ( Player1GameOver, Player2GameOver,
                      AllLevelsCompleted, GameAborted);

{$endif}