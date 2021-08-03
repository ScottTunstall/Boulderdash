{$ifndef TYPES_H_INCLUDED}
{$define TYPES_H_INCLUDED}


const OnePlayer = 1;
      TwoPlayerCoop = 2;
      TwoPlayerCompetitive =3;


type FinalOutCome = ( Player1GameOver,
                      Player2GameOver,
                      BothPlayersDead,
                      AllLevelsCompleted,
                      GameAborted );

type GameModes = (Demo, RealGame);


{$endif}
