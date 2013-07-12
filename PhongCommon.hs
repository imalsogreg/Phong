module PhongCommon where

import Graphics.Gloss
import Data.ByteString.Char8 hiding (putStrLn)

data Request = PosUpdate (Point) | StateUp

data Player = Player Point  -- Paddle Center
     	      	     Vector -- Most recent paddle velocity
            deriving (Show, Read)
                     
data Ball = Ball 
     	    {  point  ::  (Float, Float)  --place in space
     	      ,vector :: (Float, Float)  --movement Vector
	    } 
          deriving (Show, Read)

data World = World
     	   { ball :: Ball
	    ,player1 :: Player
	    ,player2 :: Player
            ,isRunning :: Bool
	   } 
           deriving (Eq, Show, Read)

data GameBoard = GameBoard { roomHeight  :: Double
                           , roomWidth   :: Double
                           , roomCenter  :: (Double,Double)
                           , paddleWidth :: Double
                           , paddleHeight :: Double
                           }
                 deriving (Eq, Show)

defaultBoard :: GameBoard
defaultBoard = GameBoard 200 200 (0,0) 10 50

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
	 put (Ball (x,y) (a,b)) = do  put (x,y)
	     	   	 	      put (a,b)
	 get = 			do (x,y) <- get
	    	    	  	   (a,b) <- get
				   return (Ball (x,y) (a,b))

instance Serialize Player where
	 put (Player (x,y) (a,b)) = do put (x,y)
	     	     	   	       put (a, b)
	 get = 			    do (x,y) <- get
	    	    	  	       (a,b) <- get
				       return (Player (x,y) (a,b))	  

instance Serialize Request where
	 put (PosUpdate p)	= do (put (0 :: Word8))
	     			     (put p)

	 put (StateUp)		= put (1 :: Word8)
         put (ToggleRunning)    = put (2 :: Word8)
	 
	 get = do t <- get :: Get Word8
                  case t of
                     0 -> do p <- get
                             return (PosUpdate p)
                     1 -> return (StateUp)
                     2 -> return (ToggleRunning)
                     n -> error $ "Tried to decode unknown constructor: #" ++ show n