
import Codec.Binary.UTF8.String (encodeString)
import Control.Monad (zipWithM_)
import Control.Monad.State.Class
import Data.List (delete, intercalate)
import Data.Map.Strict (Map, fromList, (!))
import Data.Maybe (catMaybes, isJust)
import Data.Monoid
import System.IO (Handle)

import Graphics.X11.Types
import XMonad.Core
import XMonad.Actions.SpawnOn
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
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
import XMonad.Util.NamedWindows
import XMonad.Util.WorkspaceCompare

import Debug.Trace


main :: IO ()
main = do
  n <- countScreens :: IO Int
  bars <- mapM (spawnPipe . (++) "xmobar $HOME/.config/xmonad/xmobarrc -x " . show) [0..n-1] 
  let barmap = fromList $ zip [0..n-1] bars
  xmonad $ def 
    { terminal = myTerminal
    , layoutHook = avoidStruts myLayout
    , borderWidth = 2
    , manageHook = manageDocks <+> myManageHookShift <+> manageSpawn
    , handleEventHook = docksEventHook <+> handleEventHook def
    , XMonad.Core.workspaces = myWorkSpaces
    , modMask = mod4Mask
    , logHook = dynamicLogWithPPForEachScreen xmobarPP barmap
    , startupHook = docksStartupHook <+> myStartupHook
    }
    `additionalKeysP`
    [
    -- Go to the next / prev workspace 
      ("M-<Right>", windows focusNextWS)
    , ("M-<Left>", windows focusPrevWS)
    -- Go to the next / prev screen
    , ("M-S-<Right>", windows focusNextScreen)
    , ("M-S-<Left>", windows focusPrevScreen)
    -- Shift the focused window to the next / previous workspace
    , ("M-C-<Right>", myShiftWindowToNextWS >> windows focusNextWS)
    , ("M-C-<Left>",  myShiftWindowToPrevWS >> windows focusPrevWS)
    -- Shift the focused window to the next / previous screen
    , ("M-S-C-<Right>", myShiftWindowToNextScreen >> windows focusNextScreen)
    , ("M-S-C-<Left>",  myShiftWindowToPrevScreen >> windows focusPrevScreen)
    -- Move the focus down / up 
    , ("M-k", windows focusUp)
    , ("M-j", windows focusDown)
    , ("M-h", windows focusLeft)
    , ("M-l", windows focusRight)
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
    , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +2%")
    , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -2%")
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
    className =? "Google-chrome"               --> doShift browserWorkSpace
  , className =? "Matplotlib"                  --> doFloat
  , stringProperty "WM_NAME" =? "Event Tester" --> doFloat
  ]

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

focusRight :: WindowSet -> WindowSet
focusRight ws =
  case stack . workspace $ current ws of
    Just (Stack _ u dn) | null u && not (null dn) -> focusDown ws
    _                                             -> focusNext ws
focusLeft :: WindowSet -> WindowSet
focusLeft ws =
  case stack . workspace $ current ws of
    Just (Stack _ u _) | not (null u) -> focusMaster ws
    _                                 -> focusPrev ws

focusNext :: WindowSet -> WindowSet
focusNext ws 
  | null (visible ws) = focusMaster $ focusNextWS ws
  | otherwise         = focusMaster $ focusNextScreen ws
focusPrev :: WindowSet -> WindowSet
focusPrev ws
  | null (visible ws) = focusLast $ focusPrevWS ws
  | otherwise         = focusLast $ focusPrevScreen ws
focusLast :: WindowSet -> WindowSet
focusLast ws = case stack cw of
  Just (Stack f u d) | not (null d) -> ws{ current = cs{workspace = cw{stack = Just $ Stack (last d) (reverse (init d) ++ [f] ++ u) []}}}
  _            -> ws
  where
    cs = current ws
    cw = workspace cs
focusNextWS :: WindowSet -> WindowSet
focusNextWS ws = ws{ current = (current ws){workspace = head $ hidden ws}
                   , hidden  = tail (hidden ws) ++ [workspace $ current ws]
                   }
focusPrevWS :: WindowSet -> WindowSet
focusPrevWS ws = ws{ current = (current ws){workspace = last $ hidden ws}
                   , hidden  = workspace (current ws) : init (hidden ws)
                   }
focusNextScreen :: WindowSet -> WindowSet
focusNextScreen ws 
  | null (visible ws) = ws
  | otherwise         = ws{ current = head $ visible ws
                          , visible = tail (visible ws) ++ [current ws]
                          }
focusPrevScreen :: WindowSet -> WindowSet
focusPrevScreen ws 
  | null (visible ws) = ws
  | otherwise         = ws{ current = last $ visible ws
                          , visible = current ws : init (visible ws)
                          }

-- dynamic appropriate logginf for each screen
dynamicLogWithPPForEachScreen :: PP -> Map Int Handle -> X ()
dynamicLogWithPPForEachScreen pp handlemap = do
  winset <- gets windowset 
  let screens = current winset : visible winset
  messages <- mapM (dynamicLogStringForAnScreen pp winset) screens
  io $ zipWithM_ (\(Screen _ (S n) _) message -> hPutStrLn (handlemap ! n) message) screens messages

dynamicLogStringForAnScreen :: PP -> WindowSet -> Screen WorkspaceId (Layout Window) Window ScreenId ScreenDetail ->  X String
dynamicLogStringForAnScreen pp winset s = do
  urgents <- readUrgents
  sort' <- ppSort pp
  let ws = pprWindowSetForEachScreen sort' urgents pp winset s
  title <- maybe (return "") (fmap show . getName) . fmap XMonad.StackSet.focus . stack $ workspace s
  extras <- mapM (`catchX` return Nothing)  $ ppExtras pp
  return . encodeString . sepBy (ppSep pp) . ppOrder pp $ [ws, ppLayout pp ld, ppTitle  pp $ ppTitleSanitize pp title] ++ catMaybes extras
  where
    ld = description . layout $ workspace s

pprWindowSetForEachScreen :: WorkspaceSort -> [Window] -> PP -> WindowSet -> Screen WorkspaceId (Layout Window) Window ScreenId ScreenDetail -> String
pprWindowSetForEachScreen sort' urgents pp s screen = 
  sepBy (ppWsSep pp) . map fmt . sort' $ map workspace (current s : visible s) ++ hidden s
  where 
    this = tag $ workspace screen
    visibles = Data.List.delete this $ map (tag . workspace) (current s : visible s)
    fmt w = printer pp (tag w)
      where printer | any (\x ->  (== Just (tag w)) (findTag x s)) urgents  = ppUrgent
                    | tag w == this                                               = ppCurrent
                    | tag w `elem` visibles                                       = ppVisible
                    | isJust (stack w)                                            = ppHidden
                    | otherwise                                                     = ppHiddenNoWindows

sepBy :: String -> [String] -> String
sepBy sep = intercalate sep . Prelude.filter (not . null)

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


