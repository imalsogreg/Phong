{-# LANGUAGE OverloadedStrings #-}

module PhongCommon where

import Graphics.Gloss
import qualified Data.ByteString as B
import Data.ByteString.Char8 hiding (putStrLn)
import Data.Serialize
import Data.Word
import Network
import Network.Simple.TCP
import Control.Proxy
import Control.Proxy.TCP
import System.IO

pongPort :: PortNumber
pongPort = 5227

initi :: World
initi = World (Ball (0,0) (40,2) (0,0)) (Player (-500,0) 0) (Player (500,0) 0) True

sendWithSize :: (Serialize a, Show a) => Handle -> a -> IO ()
sendWithSize h a = do
  let a' = encode a
      a'size = B.length a'
  putStrLn' $ "encode a'size is: " ++ show (encode a'size)
  B.hPut h $ encode a'size
  B.hPut h a'
  hFlush h
  putStrLn' $ Prelude.unwords ["Encoded", show a, "to", show a'size, "bytes."]
  hFlush h

getWithSize :: (Serialize a, Show a) => Handle -> IO (Either String a)
getWithSize h = do
  let intEncodedSize = B.length (encode (1 :: Int))
  putStrLn' $ "Reading " ++ show intEncodedSize ++ " bytes."
  s' <- B.hGet h intEncodedSize
  putStrLn' $ "Read these bytes " ++ show s'
  let (Right s) = decode s' :: Either String Int
  putStrLn' $ "Read them and decoded " ++ show s
  a' <- B.hGet h s
  putStrLn' $ "Reading " ++ show s ++ " bytes.  They are: " ++ show a'
  return $ decode a' 

data Request = PosUpdate WhichPaddle Point | StateUp | ToggleRunning deriving (Show, Read)

type WhichPaddle = Either () ()

data Player = Player 
              { padpoint :: Point  -- Paddle Center
     	      	,velocity ::    Float -- Most recent paddle velocity
              }
            deriving (Show, Read)
                     
data Ball = Ball 
     	    {  point  ::  (Float, Float)  --place in space
     	      ,vector :: (Float, Float)  --movement Vector
              ,score :: (Float, Float)
	    } 
          deriving (Show, Read)

data World = World
     	   { ball :: Ball
	    ,player1 :: Player
	    ,player2 :: Player
            ,isRunning :: Bool
	   } 
           deriving (Show, Read)

data GameBoard = GameBoard { roomHeight  :: Double
                           , roomWidth   :: Double
                           , roomCenter  :: (Double,Double)
                           , paddleWidth :: Double
                           , paddleHeight :: Double
                           , ballRadius  :: Double
                           }
                 deriving (Eq, Show)

defaultBoard :: GameBoard
defaultBoard = GameBoard 200 200 (0,0) 10 100 50

instance Serialize World where
	 put (World b p1 p2 r)   = do put b
                                      put p1
                                      put p2
                                      put r
	 get		 = 	 do  b <- get
	    	    	  	     p1 <- get
				     p2 <- get
                                     r  <- get
				     return (World b p1 p2 r)
instance Serialize Ball where
	 put (Ball (x,y) (a,b) (s1, s2)) = do put (x,y)
                                              put (a,b)
                                              put (s1, s2)
	 get = 			do (x,y) <- get
	    	    	  	   (a,b) <- get
                                   (s1, s2) <- get
				   return (Ball (x,y) (a,b) (s1, s2))

instance Serialize Player where
	 put (Player (x,y) v) = do put (x,y)
                                   put (v)
	 get = 			    do (x,y) <- get
                                       v <- get
				       return (Player (x,y) v)	  

instance Serialize Request where
	 put (PosUpdate w p)	= do (put (0 :: Word8))
	     			     (put w)
                                     (put p)

	 put (StateUp)		= put (1 :: Word8)
         put (ToggleRunning)    = put (2 :: Word8)
	 
	 get = do t <- get :: Get Word8
                  case t of
                     0 -> do w <- get
                             p <- get
                             return (PosUpdate w p)
                     1 -> return (StateUp)
                     2 -> return (ToggleRunning)
                     n -> error $ "Tried to decode unknown constructor: #" ++ show n

--putStrLn' = putStrLn

putStrLn':: String -> IO ()
putStrLn' = const $ return () 

{-
instance Serialize WhichPaddle where
         
         put (Either a b) =  put (Either a b)

         get =               do Either a b <- get 
                                return (Either a b)
         -}