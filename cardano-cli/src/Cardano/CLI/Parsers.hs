module Cardano.CLI.Parsers
  ( opts
  , pref
  ) where

import           Cardano.Prelude
import           Prelude (String)

import           Options.Applicative
import qualified Options.Applicative as Opt

import           Cardano.CLI.Byron.Parsers   (parseByronCommands)
import           Cardano.CLI.Run (ClientCommand(..))
import           Cardano.CLI.Shelley.Parsers (parseShelleyCommands)


opts :: ParserInfo ClientCommand
opts =
  Opt.info (parseClientCommand <**> Opt.helper)
    ( Opt.fullDesc
      <> Opt.header
      "cardano-cli - utility to support a variety of key\
      \ operations (genesis generation, migration,\
      \ pretty-printing..) for different system generations."
    )

pref :: ParserPrefs
pref = Opt.prefs showHelpOnEmpty

parseClientCommand :: Parser ClientCommand
parseClientCommand =
  asum
    [ parseByron
    , parseShelley
    , parseDisplayVersion
    ]

parseByron :: Parser ClientCommand
parseByron =
  fmap ByronCommand $
  subparser $ mconcat
    [ commandGroup "Byron specific commands"
    , metavar "Byron specific commands"
    , parseByronCommands
    ]

parseShelley :: Parser ClientCommand
parseShelley =
  subparser $ mconcat
    [ commandGroup "Shelley specific commands"
    , metavar "Shelley specific commands"
    , command'
        "shelley"
        "Shelley specific commands"
        (ShelleyCommand <$> parseShelleyCommands)
    ]

-- Yes! A --version flag or version command. Either guess is right!
parseDisplayVersion :: Parser ClientCommand
parseDisplayVersion =
      subparser
        (mconcat
         [ commandGroup "Miscellaneous commands"
         , metavar "Miscellaneous commands"
         , command'
           "version"
           "Show the cardano-cli version"
           (pure DisplayVersion)
         ]
        )
  <|> flag' DisplayVersion
        (  long "version"
        <> help "Show the cardano-cli version"
        <> hidden
        )

command' :: String -> String -> Parser a -> Opt.Mod Opt.CommandFields a
command' c descr p =
    Opt.command c $ Opt.info (p <**> Opt.helper)
              $ mconcat [ Opt.progDesc descr ]
