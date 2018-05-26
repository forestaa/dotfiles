
import Control.Monad.State.Class
import Data.Monoid


import Graphics.X11.Types
import XMonad.Core
import XMonad.Actions.SpawnOn
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout
import XMonad.Layout.IndependentScreens
import XMonad.Layout.ResizableTile
import XMonad.Main
import XMonad.ManageHook
import XMonad.Operations
import XMonad.StackSet
-- import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

import Debug.Trace

main :: IO ()
main = do
  n <- countScreens :: IO Integer
  bars <- mapM (spawnPipe . (++) "xmobar /home/foresta/dotfiles/xmonad/app/xmobarrc -x " . show) [0..n-1] 
  xmonad $ def 
    { terminal = myTerminal
    , layoutHook = avoidStruts myLayout
    , borderWidth = 2
    , manageHook = manageDocks <+> myManageHookShift <+> manageSpawn
    , handleEventHook = docksEventHook <+> handleEventHook def
    , XMonad.Core.workspaces = myWorkSpaces
    , modMask = mod4Mask
    , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = \message -> mapM_ (`hPutStrLn` message) bars }

    , startupHook = docksStartupHook <+> myStartupHook
    }
    `additionalKeysP`
    [
    -- Go to the next / prev workspace 
      ("M-<Right>", myNextWS)
    , ("M-<Left>", myPrevWS)
    -- Go to the next / prev screen
    , ("M-S-<Right>", myNextScreen)
    , ("M-S-<Left>", myPrevScreen)
    -- Shift the focused window to the next / previous workspace
    , ("M-C-<Right>", myShiftWindowToNextWS >> myNextWS)
    , ("M-C-<Left>",  myShiftWindowToPrevWS >> myPrevWS)
    -- Shift the focused window to the next / previous screen
    , ("M-S-C-<Right>", myShiftWindowToNextScreen >> myNextScreen)
    , ("M-S-C-<Left>",  myShiftWindowToPrevScreen >> myPrevScreen)
    -- Move the focus down / up 
    , ("M-k", windows focusUp)
    , ("M-j", windows focusDown)
    , ("M-h", windows focusMaster)
    , ("M-l", windows focusDown)
    , ("M-m", windows shiftMaster)
    -- Resize the focused window
    , ("M-S-j", sendMessage MirrorShrink)
    , ("M-S-k", sendMessage MirrorExpand)
    , ("M-S-h", sendMessage Shrink)
    , ("M-S-l", sendMessage Expand)
    -- Close the focused window
    , ("M-C-c", kill)
    , ("M-C-d", debug)
    ]
    `additionalKeysP`
    [
      ("M-C-l",      spawn "light-locker-command -l")
    , ("M-<Return>", spawn myTerminal)
    ]


debug :: X ()
debug = do
  w <- gets  windowset
  traceShow (show w) $ return ()
  -- c <- ask
  -- traceShow (show c) $ return ()
  -- n <- io countScreens :: X Integer
  -- traceShow (show n) $ return ()
  -- n <- XS.get :: X ScreenCount
  -- traceShow (show n) $ return ()
  -- s <- get
  -- traceShow (show s) $ return ()

myTerminal :: String
myTerminal = "urxvtc"
myWorkSpaces :: [String]
myWorkSpaces = [mainWorkSpace, browserWorkSpace, "temp1", "temp2", "temp3"]
mainWorkSpace :: String
mainWorkSpace = "  main  "
browserWorkSpace :: String
browserWorkSpace = "  browser  "

myStartupHook :: X ()
myStartupHook = do
  -- spawnOnce "urxvtd -q -o -f" -- we call the deamon in .xprofile to start urxvtc in XMonad when startup
  -- spawnOnce "urxvtc -e tmux"
  spawnOnce "urxvtc" 
  spawnOnce "google-chrome-stable 1>/dev/null 2>&1"

myLayout :: Choose ResizableTall Full a
myLayout = ResizableTall 1 (3/100) (1/2) [] ||| Full

-- if you want to know className, run the command: "$ xprop|grep CLASS"
myManageHookShift :: Query (Endo WindowSet)
myManageHookShift = composeAll 
  [
    className =? "Google-chrome" --> doShift browserWorkSpace
  , stringProperty "WM_NAME" =? "Event Tester" --> doFloat
  ]

myNextWS :: X ()
myNextWS = windows $ \ws -> ws{ current = (current ws){workspace = head $ hidden ws}
                              , hidden  = tail (hidden ws) ++ [workspace $ current ws]
                              }
myPrevWS :: X ()
myPrevWS = windows $ \ws -> ws{ current = (current ws){workspace = last $ hidden ws}
                              , hidden  = workspace (current ws) : init (hidden ws)
                              }
myNextScreen :: X ()
myNextScreen = windows $ \ws -> ws{ current = head $ visible ws
                                  , visible = tail (visible ws) ++ [current ws]
                                  }
myPrevScreen :: X ()
myPrevScreen = windows $ \ws -> ws{ current = last $ visible ws
                                  , visible = current ws : init (visible ws)
                                  }

data ScreenWS = SCreen | WS
myShiftWindowTo :: ScreenWS -> Direction1D -> X ()
myShiftWindowTo sws d = windows $ \ws ->
  let currScreen = current ws 
      currWorkSpace = workspace currScreen
      currStack = stack currWorkSpace
   in case currStack of
        Just s@(Stack f _ _)  -> 
          case sws of
            WS -> 
              let hiddens = hidden ws
                  hidden' = case d of
                      Next -> addFocused f (head hiddens) : tail hiddens
                      Prev -> init hiddens ++ [addFocused f $ last hiddens]
               in ws{ current =  currScreen{ workspace = currWorkSpace{stack = removeFocused s}}
                    , hidden = hidden'
                    }
            SCreen -> 
              let visibles = visible ws  
                  visible' = case d of
                      Next -> let headvisible = head visibles
                               in headvisible{ workspace = addFocused f (workspace headvisible)} : tail visibles
                      Prev -> let lastvisible = last visibles 
                               in init visibles ++ [lastvisible{ workspace = addFocused f (workspace lastvisible)}]
               in ws{ current = currScreen{ workspace = currWorkSpace{stack = removeFocused s}}
                    , visible = visible' 
                    }
        Nothing -> ws

myShiftWindowToNextWS :: X ()
myShiftWindowToNextWS = myShiftWindowTo WS Next
myShiftWindowToPrevWS :: X ()
myShiftWindowToPrevWS = myShiftWindowTo WS Prev
myShiftWindowToNextScreen :: X ()
myShiftWindowToNextScreen = myShiftWindowTo SCreen Next
myShiftWindowToPrevScreen :: X ()
myShiftWindowToPrevScreen = myShiftWindowTo SCreen Prev

removeFocused :: Stack a-> Maybe (Stack a)
removeFocused (Stack _ [] [])      = Nothing
removeFocused (Stack _ [] (w:ws))  = Just $ Stack w [] ws
removeFocused (Stack _ (w:ws) ws') = Just $ Stack w ws ws'

addFocused :: a -> Workspace i l a -> Workspace i l a
addFocused a w@Workspace{stack = Nothing} = w{stack = Just $ Stack a [] []}
addFocused a w@Workspace{stack = Just s}  = w{stack = Just $ s{XMonad.StackSet.focus = a, up = [], down = integrate s}}

-- data ScreenCount = forall i. Integral i => ScreenCount i
-- newtype ScreenCount = ScreenCount { screencount :: Integer } deriving (Show)
-- instance ExtensionClass ScreenCount where
--   initialValue = ScreenCount 1

-- screenRearrange ::
---- instance Show XState where
--   show s = intercalate "\n" [ "windowset      = ", show $ windowset s
--                             , "mapped         = ", show $ mapped s
--                             , "waitingUnmap   = ", show $ waitingUnmap s
--                             , "numberlockMask = ", show $ numberlockMask s
--                             ]


