-- Filter Specifications:
--
-- Sample Rate     : 1 MHz
-- Response        : Lowpass
-- Specification   : Fp,Fst,Ap,Ast
-- Passband Ripple : 0.1 dB
-- Stopband Atten. : 80 dB
-- Passband Edge   : 125 kHz
-- Stopband Edge   : 135 kHz
-- -------------------------------------------------------------
-- -------------------------------------------------------------
-- HDL Implementation    : Fully Serial
-- Folding Factor        : 341
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Direct-Form FIR
-- Filter Length     : 341
-- Stable            : Yes
-- Linear Phase      : Yes (Type 1)
-- Arithmetic        : fixed
-- Numerator         : s16,16 -> [-5.000000e-01 5.000000e-01)
-- Input             : s32,31 -> [-1 1)
-- Filter Internals  : Full Precision
--   Output          : s50,47 -> [-4 4)  (auto determined)
--   Product         : s47,47 -> [-5.000000e-01 5.000000e-01)  (auto determined)
--   Accumulator     : s50,47 -> [-4 4)  (auto determined)
--   Round Mode      : No rounding
--   Overflow Mode   : No overflow
-- -------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY fir_filter IS
   PORT( I_CLK                           :   IN    std_logic; 
         I_RST                           :   IN    std_logic; 
         I_FILTER                        :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En31
         O_FILTER                        :   OUT   std_logic_vector(49 DOWNTO 0)  -- sfix50_En47
         );

END fir_filter;


----------------------------------------------------------------
--Module Architecture: fir_filter
----------------------------------------------------------------
ARCHITECTURE rtl OF fir_filter IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En31
  -- Constants
  CONSTANT coeff1                         : signed(15 DOWNTO 0) := to_signed(8, 16); -- sfix16_En16
  CONSTANT coeff2                         : signed(15 DOWNTO 0) := to_signed(15, 16); -- sfix16_En16
  CONSTANT coeff3                         : signed(15 DOWNTO 0) := to_signed(21, 16); -- sfix16_En16
  CONSTANT coeff4                         : signed(15 DOWNTO 0) := to_signed(22, 16); -- sfix16_En16
  CONSTANT coeff5                         : signed(15 DOWNTO 0) := to_signed(15, 16); -- sfix16_En16
  CONSTANT coeff6                         : signed(15 DOWNTO 0) := to_signed(-1, 16); -- sfix16_En16
  CONSTANT coeff7                         : signed(15 DOWNTO 0) := to_signed(-21, 16); -- sfix16_En16
  CONSTANT coeff8                         : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En16
  CONSTANT coeff9                         : signed(15 DOWNTO 0) := to_signed(-47, 16); -- sfix16_En16
  CONSTANT coeff10                        : signed(15 DOWNTO 0) := to_signed(-43, 16); -- sfix16_En16
  CONSTANT coeff11                        : signed(15 DOWNTO 0) := to_signed(-27, 16); -- sfix16_En16
  CONSTANT coeff12                        : signed(15 DOWNTO 0) := to_signed(-8, 16); -- sfix16_En16
  CONSTANT coeff13                        : signed(15 DOWNTO 0) := to_signed(5, 16); -- sfix16_En16
  CONSTANT coeff14                        : signed(15 DOWNTO 0) := to_signed(8, 16); -- sfix16_En16
  CONSTANT coeff15                        : signed(15 DOWNTO 0) := to_signed(-1, 16); -- sfix16_En16
  CONSTANT coeff16                        : signed(15 DOWNTO 0) := to_signed(-15, 16); -- sfix16_En16
  CONSTANT coeff17                        : signed(15 DOWNTO 0) := to_signed(-25, 16); -- sfix16_En16
  CONSTANT coeff18                        : signed(15 DOWNTO 0) := to_signed(-24, 16); -- sfix16_En16
  CONSTANT coeff19                        : signed(15 DOWNTO 0) := to_signed(-12, 16); -- sfix16_En16
  CONSTANT coeff20                        : signed(15 DOWNTO 0) := to_signed(5, 16); -- sfix16_En16
  CONSTANT coeff21                        : signed(15 DOWNTO 0) := to_signed(16, 16); -- sfix16_En16
  CONSTANT coeff22                        : signed(15 DOWNTO 0) := to_signed(16, 16); -- sfix16_En16
  CONSTANT coeff23                        : signed(15 DOWNTO 0) := to_signed(3, 16); -- sfix16_En16
  CONSTANT coeff24                        : signed(15 DOWNTO 0) := to_signed(-14, 16); -- sfix16_En16
  CONSTANT coeff25                        : signed(15 DOWNTO 0) := to_signed(-25, 16); -- sfix16_En16
  CONSTANT coeff26                        : signed(15 DOWNTO 0) := to_signed(-22, 16); -- sfix16_En16
  CONSTANT coeff27                        : signed(15 DOWNTO 0) := to_signed(-6, 16); -- sfix16_En16
  CONSTANT coeff28                        : signed(15 DOWNTO 0) := to_signed(14, 16); -- sfix16_En16
  CONSTANT coeff29                        : signed(15 DOWNTO 0) := to_signed(25, 16); -- sfix16_En16
  CONSTANT coeff30                        : signed(15 DOWNTO 0) := to_signed(21, 16); -- sfix16_En16
  CONSTANT coeff31                        : signed(15 DOWNTO 0) := to_signed(2, 16); -- sfix16_En16
  CONSTANT coeff32                        : signed(15 DOWNTO 0) := to_signed(-19, 16); -- sfix16_En16
  CONSTANT coeff33                        : signed(15 DOWNTO 0) := to_signed(-31, 16); -- sfix16_En16
  CONSTANT coeff34                        : signed(15 DOWNTO 0) := to_signed(-24, 16); -- sfix16_En16
  CONSTANT coeff35                        : signed(15 DOWNTO 0) := to_signed(-2, 16); -- sfix16_En16
  CONSTANT coeff36                        : signed(15 DOWNTO 0) := to_signed(23, 16); -- sfix16_En16
  CONSTANT coeff37                        : signed(15 DOWNTO 0) := to_signed(34, 16); -- sfix16_En16
  CONSTANT coeff38                        : signed(15 DOWNTO 0) := to_signed(24, 16); -- sfix16_En16
  CONSTANT coeff39                        : signed(15 DOWNTO 0) := to_signed(-2, 16); -- sfix16_En16
  CONSTANT coeff40                        : signed(15 DOWNTO 0) := to_signed(-29, 16); -- sfix16_En16
  CONSTANT coeff41                        : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En16
  CONSTANT coeff42                        : signed(15 DOWNTO 0) := to_signed(-26, 16); -- sfix16_En16
  CONSTANT coeff43                        : signed(15 DOWNTO 0) := to_signed(5, 16); -- sfix16_En16
  CONSTANT coeff44                        : signed(15 DOWNTO 0) := to_signed(34, 16); -- sfix16_En16
  CONSTANT coeff45                        : signed(15 DOWNTO 0) := to_signed(44, 16); -- sfix16_En16
  CONSTANT coeff46                        : signed(15 DOWNTO 0) := to_signed(26, 16); -- sfix16_En16
  CONSTANT coeff47                        : signed(15 DOWNTO 0) := to_signed(-9, 16); -- sfix16_En16
  CONSTANT coeff48                        : signed(15 DOWNTO 0) := to_signed(-41, 16); -- sfix16_En16
  CONSTANT coeff49                        : signed(15 DOWNTO 0) := to_signed(-49, 16); -- sfix16_En16
  CONSTANT coeff50                        : signed(15 DOWNTO 0) := to_signed(-26, 16); -- sfix16_En16
  CONSTANT coeff51                        : signed(15 DOWNTO 0) := to_signed(15, 16); -- sfix16_En16
  CONSTANT coeff52                        : signed(15 DOWNTO 0) := to_signed(49, 16); -- sfix16_En16
  CONSTANT coeff53                        : signed(15 DOWNTO 0) := to_signed(54, 16); -- sfix16_En16
  CONSTANT coeff54                        : signed(15 DOWNTO 0) := to_signed(25, 16); -- sfix16_En16
  CONSTANT coeff55                        : signed(15 DOWNTO 0) := to_signed(-21, 16); -- sfix16_En16
  CONSTANT coeff56                        : signed(15 DOWNTO 0) := to_signed(-57, 16); -- sfix16_En16
  CONSTANT coeff57                        : signed(15 DOWNTO 0) := to_signed(-59, 16); -- sfix16_En16
  CONSTANT coeff58                        : signed(15 DOWNTO 0) := to_signed(-23, 16); -- sfix16_En16
  CONSTANT coeff59                        : signed(15 DOWNTO 0) := to_signed(29, 16); -- sfix16_En16
  CONSTANT coeff60                        : signed(15 DOWNTO 0) := to_signed(66, 16); -- sfix16_En16
  CONSTANT coeff61                        : signed(15 DOWNTO 0) := to_signed(63, 16); -- sfix16_En16
  CONSTANT coeff62                        : signed(15 DOWNTO 0) := to_signed(20, 16); -- sfix16_En16
  CONSTANT coeff63                        : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En16
  CONSTANT coeff64                        : signed(15 DOWNTO 0) := to_signed(-76, 16); -- sfix16_En16
  CONSTANT coeff65                        : signed(15 DOWNTO 0) := to_signed(-67, 16); -- sfix16_En16
  CONSTANT coeff66                        : signed(15 DOWNTO 0) := to_signed(-15, 16); -- sfix16_En16
  CONSTANT coeff67                        : signed(15 DOWNTO 0) := to_signed(49, 16); -- sfix16_En16
  CONSTANT coeff68                        : signed(15 DOWNTO 0) := to_signed(86, 16); -- sfix16_En16
  CONSTANT coeff69                        : signed(15 DOWNTO 0) := to_signed(70, 16); -- sfix16_En16
  CONSTANT coeff70                        : signed(15 DOWNTO 0) := to_signed(9, 16); -- sfix16_En16
  CONSTANT coeff71                        : signed(15 DOWNTO 0) := to_signed(-62, 16); -- sfix16_En16
  CONSTANT coeff72                        : signed(15 DOWNTO 0) := to_signed(-97, 16); -- sfix16_En16
  CONSTANT coeff73                        : signed(15 DOWNTO 0) := to_signed(-72, 16); -- sfix16_En16
  CONSTANT coeff74                        : signed(15 DOWNTO 0) := to_signed(-1, 16); -- sfix16_En16
  CONSTANT coeff75                        : signed(15 DOWNTO 0) := to_signed(75, 16); -- sfix16_En16
  CONSTANT coeff76                        : signed(15 DOWNTO 0) := to_signed(108, 16); -- sfix16_En16
  CONSTANT coeff77                        : signed(15 DOWNTO 0) := to_signed(73, 16); -- sfix16_En16
  CONSTANT coeff78                        : signed(15 DOWNTO 0) := to_signed(-10, 16); -- sfix16_En16
  CONSTANT coeff79                        : signed(15 DOWNTO 0) := to_signed(-91, 16); -- sfix16_En16
  CONSTANT coeff80                        : signed(15 DOWNTO 0) := to_signed(-119, 16); -- sfix16_En16
  CONSTANT coeff81                        : signed(15 DOWNTO 0) := to_signed(-73, 16); -- sfix16_En16
  CONSTANT coeff82                        : signed(15 DOWNTO 0) := to_signed(22, 16); -- sfix16_En16
  CONSTANT coeff83                        : signed(15 DOWNTO 0) := to_signed(108, 16); -- sfix16_En16
  CONSTANT coeff84                        : signed(15 DOWNTO 0) := to_signed(130, 16); -- sfix16_En16
  CONSTANT coeff85                        : signed(15 DOWNTO 0) := to_signed(70, 16); -- sfix16_En16
  CONSTANT coeff86                        : signed(15 DOWNTO 0) := to_signed(-37, 16); -- sfix16_En16
  CONSTANT coeff87                        : signed(15 DOWNTO 0) := to_signed(-126, 16); -- sfix16_En16
  CONSTANT coeff88                        : signed(15 DOWNTO 0) := to_signed(-140, 16); -- sfix16_En16
  CONSTANT coeff89                        : signed(15 DOWNTO 0) := to_signed(-65, 16); -- sfix16_En16
  CONSTANT coeff90                        : signed(15 DOWNTO 0) := to_signed(55, 16); -- sfix16_En16
  CONSTANT coeff91                        : signed(15 DOWNTO 0) := to_signed(146, 16); -- sfix16_En16
  CONSTANT coeff92                        : signed(15 DOWNTO 0) := to_signed(149, 16); -- sfix16_En16
  CONSTANT coeff93                        : signed(15 DOWNTO 0) := to_signed(58, 16); -- sfix16_En16
  CONSTANT coeff94                        : signed(15 DOWNTO 0) := to_signed(-76, 16); -- sfix16_En16
  CONSTANT coeff95                        : signed(15 DOWNTO 0) := to_signed(-168, 16); -- sfix16_En16
  CONSTANT coeff96                        : signed(15 DOWNTO 0) := to_signed(-158, 16); -- sfix16_En16
  CONSTANT coeff97                        : signed(15 DOWNTO 0) := to_signed(-47, 16); -- sfix16_En16
  CONSTANT coeff98                        : signed(15 DOWNTO 0) := to_signed(100, 16); -- sfix16_En16
  CONSTANT coeff99                        : signed(15 DOWNTO 0) := to_signed(190, 16); -- sfix16_En16
  CONSTANT coeff100                       : signed(15 DOWNTO 0) := to_signed(165, 16); -- sfix16_En16
  CONSTANT coeff101                       : signed(15 DOWNTO 0) := to_signed(33, 16); -- sfix16_En16
  CONSTANT coeff102                       : signed(15 DOWNTO 0) := to_signed(-127, 16); -- sfix16_En16
  CONSTANT coeff103                       : signed(15 DOWNTO 0) := to_signed(-214, 16); -- sfix16_En16
  CONSTANT coeff104                       : signed(15 DOWNTO 0) := to_signed(-169, 16); -- sfix16_En16
  CONSTANT coeff105                       : signed(15 DOWNTO 0) := to_signed(-15, 16); -- sfix16_En16
  CONSTANT coeff106                       : signed(15 DOWNTO 0) := to_signed(158, 16); -- sfix16_En16
  CONSTANT coeff107                       : signed(15 DOWNTO 0) := to_signed(238, 16); -- sfix16_En16
  CONSTANT coeff108                       : signed(15 DOWNTO 0) := to_signed(172, 16); -- sfix16_En16
  CONSTANT coeff109                       : signed(15 DOWNTO 0) := to_signed(-8, 16); -- sfix16_En16
  CONSTANT coeff110                       : signed(15 DOWNTO 0) := to_signed(-192, 16); -- sfix16_En16
  CONSTANT coeff111                       : signed(15 DOWNTO 0) := to_signed(-264, 16); -- sfix16_En16
  CONSTANT coeff112                       : signed(15 DOWNTO 0) := to_signed(-171, 16); -- sfix16_En16
  CONSTANT coeff113                       : signed(15 DOWNTO 0) := to_signed(36, 16); -- sfix16_En16
  CONSTANT coeff114                       : signed(15 DOWNTO 0) := to_signed(231, 16); -- sfix16_En16
  CONSTANT coeff115                       : signed(15 DOWNTO 0) := to_signed(289, 16); -- sfix16_En16
  CONSTANT coeff116                       : signed(15 DOWNTO 0) := to_signed(166, 16); -- sfix16_En16
  CONSTANT coeff117                       : signed(15 DOWNTO 0) := to_signed(-70, 16); -- sfix16_En16
  CONSTANT coeff118                       : signed(15 DOWNTO 0) := to_signed(-274, 16); -- sfix16_En16
  CONSTANT coeff119                       : signed(15 DOWNTO 0) := to_signed(-315, 16); -- sfix16_En16
  CONSTANT coeff120                       : signed(15 DOWNTO 0) := to_signed(-157, 16); -- sfix16_En16
  CONSTANT coeff121                       : signed(15 DOWNTO 0) := to_signed(110, 16); -- sfix16_En16
  CONSTANT coeff122                       : signed(15 DOWNTO 0) := to_signed(322, 16); -- sfix16_En16
  CONSTANT coeff123                       : signed(15 DOWNTO 0) := to_signed(340, 16); -- sfix16_En16
  CONSTANT coeff124                       : signed(15 DOWNTO 0) := to_signed(142, 16); -- sfix16_En16
  CONSTANT coeff125                       : signed(15 DOWNTO 0) := to_signed(-159, 16); -- sfix16_En16
  CONSTANT coeff126                       : signed(15 DOWNTO 0) := to_signed(-376, 16); -- sfix16_En16
  CONSTANT coeff127                       : signed(15 DOWNTO 0) := to_signed(-365, 16); -- sfix16_En16
  CONSTANT coeff128                       : signed(15 DOWNTO 0) := to_signed(-120, 16); -- sfix16_En16
  CONSTANT coeff129                       : signed(15 DOWNTO 0) := to_signed(217, 16); -- sfix16_En16
  CONSTANT coeff130                       : signed(15 DOWNTO 0) := to_signed(436, 16); -- sfix16_En16
  CONSTANT coeff131                       : signed(15 DOWNTO 0) := to_signed(389, 16); -- sfix16_En16
  CONSTANT coeff132                       : signed(15 DOWNTO 0) := to_signed(90, 16); -- sfix16_En16
  CONSTANT coeff133                       : signed(15 DOWNTO 0) := to_signed(-287, 16); -- sfix16_En16
  CONSTANT coeff134                       : signed(15 DOWNTO 0) := to_signed(-504, 16); -- sfix16_En16
  CONSTANT coeff135                       : signed(15 DOWNTO 0) := to_signed(-412, 16); -- sfix16_En16
  CONSTANT coeff136                       : signed(15 DOWNTO 0) := to_signed(-49, 16); -- sfix16_En16
  CONSTANT coeff137                       : signed(15 DOWNTO 0) := to_signed(371, 16); -- sfix16_En16
  CONSTANT coeff138                       : signed(15 DOWNTO 0) := to_signed(582, 16); -- sfix16_En16
  CONSTANT coeff139                       : signed(15 DOWNTO 0) := to_signed(433, 16); -- sfix16_En16
  CONSTANT coeff140                       : signed(15 DOWNTO 0) := to_signed(-6, 16); -- sfix16_En16
  CONSTANT coeff141                       : signed(15 DOWNTO 0) := to_signed(-475, 16); -- sfix16_En16
  CONSTANT coeff142                       : signed(15 DOWNTO 0) := to_signed(-674, 16); -- sfix16_En16
  CONSTANT coeff143                       : signed(15 DOWNTO 0) := to_signed(-453, 16); -- sfix16_En16
  CONSTANT coeff144                       : signed(15 DOWNTO 0) := to_signed(80, 16); -- sfix16_En16
  CONSTANT coeff145                       : signed(15 DOWNTO 0) := to_signed(607, 16); -- sfix16_En16
  CONSTANT coeff146                       : signed(15 DOWNTO 0) := to_signed(786, 16); -- sfix16_En16
  CONSTANT coeff147                       : signed(15 DOWNTO 0) := to_signed(471, 16); -- sfix16_En16
  CONSTANT coeff148                       : signed(15 DOWNTO 0) := to_signed(-181, 16); -- sfix16_En16
  CONSTANT coeff149                       : signed(15 DOWNTO 0) := to_signed(-779, 16); -- sfix16_En16
  CONSTANT coeff150                       : signed(15 DOWNTO 0) := to_signed(-929, 16); -- sfix16_En16
  CONSTANT coeff151                       : signed(15 DOWNTO 0) := to_signed(-486, 16); -- sfix16_En16
  CONSTANT coeff152                       : signed(15 DOWNTO 0) := to_signed(325, 16); -- sfix16_En16
  CONSTANT coeff153                       : signed(15 DOWNTO 0) := to_signed(1018, 16); -- sfix16_En16
  CONSTANT coeff154                       : signed(15 DOWNTO 0) := to_signed(1124, 16); -- sfix16_En16
  CONSTANT coeff155                       : signed(15 DOWNTO 0) := to_signed(499, 16); -- sfix16_En16
  CONSTANT coeff156                       : signed(15 DOWNTO 0) := to_signed(-544, 16); -- sfix16_En16
  CONSTANT coeff157                       : signed(15 DOWNTO 0) := to_signed(-1379, 16); -- sfix16_En16
  CONSTANT coeff158                       : signed(15 DOWNTO 0) := to_signed(-1420, 16); -- sfix16_En16
  CONSTANT coeff159                       : signed(15 DOWNTO 0) := to_signed(-510, 16); -- sfix16_En16
  CONSTANT coeff160                       : signed(15 DOWNTO 0) := to_signed(917, 16); -- sfix16_En16
  CONSTANT coeff161                       : signed(15 DOWNTO 0) := to_signed(2006, 16); -- sfix16_En16
  CONSTANT coeff162                       : signed(15 DOWNTO 0) := to_signed(1952, 16); -- sfix16_En16
  CONSTANT coeff163                       : signed(15 DOWNTO 0) := to_signed(517, 16); -- sfix16_En16
  CONSTANT coeff164                       : signed(15 DOWNTO 0) := to_signed(-1701, 16); -- sfix16_En16
  CONSTANT coeff165                       : signed(15 DOWNTO 0) := to_signed(-3428, 16); -- sfix16_En16
  CONSTANT coeff166                       : signed(15 DOWNTO 0) := to_signed(-3290, 16); -- sfix16_En16
  CONSTANT coeff167                       : signed(15 DOWNTO 0) := to_signed(-522, 16); -- sfix16_En16
  CONSTANT coeff168                       : signed(15 DOWNTO 0) := to_signed(4530, 16); -- sfix16_En16
  CONSTANT coeff169                       : signed(15 DOWNTO 0) := to_signed(10414, 16); -- sfix16_En16
  CONSTANT coeff170                       : signed(15 DOWNTO 0) := to_signed(15115, 16); -- sfix16_En16
  CONSTANT coeff171                       : signed(15 DOWNTO 0) := to_signed(16907, 16); -- sfix16_En16
  CONSTANT coeff172                       : signed(15 DOWNTO 0) := to_signed(15115, 16); -- sfix16_En16
  CONSTANT coeff173                       : signed(15 DOWNTO 0) := to_signed(10414, 16); -- sfix16_En16
  CONSTANT coeff174                       : signed(15 DOWNTO 0) := to_signed(4530, 16); -- sfix16_En16
  CONSTANT coeff175                       : signed(15 DOWNTO 0) := to_signed(-522, 16); -- sfix16_En16
  CONSTANT coeff176                       : signed(15 DOWNTO 0) := to_signed(-3290, 16); -- sfix16_En16
  CONSTANT coeff177                       : signed(15 DOWNTO 0) := to_signed(-3428, 16); -- sfix16_En16
  CONSTANT coeff178                       : signed(15 DOWNTO 0) := to_signed(-1701, 16); -- sfix16_En16
  CONSTANT coeff179                       : signed(15 DOWNTO 0) := to_signed(517, 16); -- sfix16_En16
  CONSTANT coeff180                       : signed(15 DOWNTO 0) := to_signed(1952, 16); -- sfix16_En16
  CONSTANT coeff181                       : signed(15 DOWNTO 0) := to_signed(2006, 16); -- sfix16_En16
  CONSTANT coeff182                       : signed(15 DOWNTO 0) := to_signed(917, 16); -- sfix16_En16
  CONSTANT coeff183                       : signed(15 DOWNTO 0) := to_signed(-510, 16); -- sfix16_En16
  CONSTANT coeff184                       : signed(15 DOWNTO 0) := to_signed(-1420, 16); -- sfix16_En16
  CONSTANT coeff185                       : signed(15 DOWNTO 0) := to_signed(-1379, 16); -- sfix16_En16
  CONSTANT coeff186                       : signed(15 DOWNTO 0) := to_signed(-544, 16); -- sfix16_En16
  CONSTANT coeff187                       : signed(15 DOWNTO 0) := to_signed(499, 16); -- sfix16_En16
  CONSTANT coeff188                       : signed(15 DOWNTO 0) := to_signed(1124, 16); -- sfix16_En16
  CONSTANT coeff189                       : signed(15 DOWNTO 0) := to_signed(1018, 16); -- sfix16_En16
  CONSTANT coeff190                       : signed(15 DOWNTO 0) := to_signed(325, 16); -- sfix16_En16
  CONSTANT coeff191                       : signed(15 DOWNTO 0) := to_signed(-486, 16); -- sfix16_En16
  CONSTANT coeff192                       : signed(15 DOWNTO 0) := to_signed(-929, 16); -- sfix16_En16
  CONSTANT coeff193                       : signed(15 DOWNTO 0) := to_signed(-779, 16); -- sfix16_En16
  CONSTANT coeff194                       : signed(15 DOWNTO 0) := to_signed(-181, 16); -- sfix16_En16
  CONSTANT coeff195                       : signed(15 DOWNTO 0) := to_signed(471, 16); -- sfix16_En16
  CONSTANT coeff196                       : signed(15 DOWNTO 0) := to_signed(786, 16); -- sfix16_En16
  CONSTANT coeff197                       : signed(15 DOWNTO 0) := to_signed(607, 16); -- sfix16_En16
  CONSTANT coeff198                       : signed(15 DOWNTO 0) := to_signed(80, 16); -- sfix16_En16
  CONSTANT coeff199                       : signed(15 DOWNTO 0) := to_signed(-453, 16); -- sfix16_En16
  CONSTANT coeff200                       : signed(15 DOWNTO 0) := to_signed(-674, 16); -- sfix16_En16
  CONSTANT coeff201                       : signed(15 DOWNTO 0) := to_signed(-475, 16); -- sfix16_En16
  CONSTANT coeff202                       : signed(15 DOWNTO 0) := to_signed(-6, 16); -- sfix16_En16
  CONSTANT coeff203                       : signed(15 DOWNTO 0) := to_signed(433, 16); -- sfix16_En16
  CONSTANT coeff204                       : signed(15 DOWNTO 0) := to_signed(582, 16); -- sfix16_En16
  CONSTANT coeff205                       : signed(15 DOWNTO 0) := to_signed(371, 16); -- sfix16_En16
  CONSTANT coeff206                       : signed(15 DOWNTO 0) := to_signed(-49, 16); -- sfix16_En16
  CONSTANT coeff207                       : signed(15 DOWNTO 0) := to_signed(-412, 16); -- sfix16_En16
  CONSTANT coeff208                       : signed(15 DOWNTO 0) := to_signed(-504, 16); -- sfix16_En16
  CONSTANT coeff209                       : signed(15 DOWNTO 0) := to_signed(-287, 16); -- sfix16_En16
  CONSTANT coeff210                       : signed(15 DOWNTO 0) := to_signed(90, 16); -- sfix16_En16
  CONSTANT coeff211                       : signed(15 DOWNTO 0) := to_signed(389, 16); -- sfix16_En16
  CONSTANT coeff212                       : signed(15 DOWNTO 0) := to_signed(436, 16); -- sfix16_En16
  CONSTANT coeff213                       : signed(15 DOWNTO 0) := to_signed(217, 16); -- sfix16_En16
  CONSTANT coeff214                       : signed(15 DOWNTO 0) := to_signed(-120, 16); -- sfix16_En16
  CONSTANT coeff215                       : signed(15 DOWNTO 0) := to_signed(-365, 16); -- sfix16_En16
  CONSTANT coeff216                       : signed(15 DOWNTO 0) := to_signed(-376, 16); -- sfix16_En16
  CONSTANT coeff217                       : signed(15 DOWNTO 0) := to_signed(-159, 16); -- sfix16_En16
  CONSTANT coeff218                       : signed(15 DOWNTO 0) := to_signed(142, 16); -- sfix16_En16
  CONSTANT coeff219                       : signed(15 DOWNTO 0) := to_signed(340, 16); -- sfix16_En16
  CONSTANT coeff220                       : signed(15 DOWNTO 0) := to_signed(322, 16); -- sfix16_En16
  CONSTANT coeff221                       : signed(15 DOWNTO 0) := to_signed(110, 16); -- sfix16_En16
  CONSTANT coeff222                       : signed(15 DOWNTO 0) := to_signed(-157, 16); -- sfix16_En16
  CONSTANT coeff223                       : signed(15 DOWNTO 0) := to_signed(-315, 16); -- sfix16_En16
  CONSTANT coeff224                       : signed(15 DOWNTO 0) := to_signed(-274, 16); -- sfix16_En16
  CONSTANT coeff225                       : signed(15 DOWNTO 0) := to_signed(-70, 16); -- sfix16_En16
  CONSTANT coeff226                       : signed(15 DOWNTO 0) := to_signed(166, 16); -- sfix16_En16
  CONSTANT coeff227                       : signed(15 DOWNTO 0) := to_signed(289, 16); -- sfix16_En16
  CONSTANT coeff228                       : signed(15 DOWNTO 0) := to_signed(231, 16); -- sfix16_En16
  CONSTANT coeff229                       : signed(15 DOWNTO 0) := to_signed(36, 16); -- sfix16_En16
  CONSTANT coeff230                       : signed(15 DOWNTO 0) := to_signed(-171, 16); -- sfix16_En16
  CONSTANT coeff231                       : signed(15 DOWNTO 0) := to_signed(-264, 16); -- sfix16_En16
  CONSTANT coeff232                       : signed(15 DOWNTO 0) := to_signed(-192, 16); -- sfix16_En16
  CONSTANT coeff233                       : signed(15 DOWNTO 0) := to_signed(-8, 16); -- sfix16_En16
  CONSTANT coeff234                       : signed(15 DOWNTO 0) := to_signed(172, 16); -- sfix16_En16
  CONSTANT coeff235                       : signed(15 DOWNTO 0) := to_signed(238, 16); -- sfix16_En16
  CONSTANT coeff236                       : signed(15 DOWNTO 0) := to_signed(158, 16); -- sfix16_En16
  CONSTANT coeff237                       : signed(15 DOWNTO 0) := to_signed(-15, 16); -- sfix16_En16
  CONSTANT coeff238                       : signed(15 DOWNTO 0) := to_signed(-169, 16); -- sfix16_En16
  CONSTANT coeff239                       : signed(15 DOWNTO 0) := to_signed(-214, 16); -- sfix16_En16
  CONSTANT coeff240                       : signed(15 DOWNTO 0) := to_signed(-127, 16); -- sfix16_En16
  CONSTANT coeff241                       : signed(15 DOWNTO 0) := to_signed(33, 16); -- sfix16_En16
  CONSTANT coeff242                       : signed(15 DOWNTO 0) := to_signed(165, 16); -- sfix16_En16
  CONSTANT coeff243                       : signed(15 DOWNTO 0) := to_signed(190, 16); -- sfix16_En16
  CONSTANT coeff244                       : signed(15 DOWNTO 0) := to_signed(100, 16); -- sfix16_En16
  CONSTANT coeff245                       : signed(15 DOWNTO 0) := to_signed(-47, 16); -- sfix16_En16
  CONSTANT coeff246                       : signed(15 DOWNTO 0) := to_signed(-158, 16); -- sfix16_En16
  CONSTANT coeff247                       : signed(15 DOWNTO 0) := to_signed(-168, 16); -- sfix16_En16
  CONSTANT coeff248                       : signed(15 DOWNTO 0) := to_signed(-76, 16); -- sfix16_En16
  CONSTANT coeff249                       : signed(15 DOWNTO 0) := to_signed(58, 16); -- sfix16_En16
  CONSTANT coeff250                       : signed(15 DOWNTO 0) := to_signed(149, 16); -- sfix16_En16
  CONSTANT coeff251                       : signed(15 DOWNTO 0) := to_signed(146, 16); -- sfix16_En16
  CONSTANT coeff252                       : signed(15 DOWNTO 0) := to_signed(55, 16); -- sfix16_En16
  CONSTANT coeff253                       : signed(15 DOWNTO 0) := to_signed(-65, 16); -- sfix16_En16
  CONSTANT coeff254                       : signed(15 DOWNTO 0) := to_signed(-140, 16); -- sfix16_En16
  CONSTANT coeff255                       : signed(15 DOWNTO 0) := to_signed(-126, 16); -- sfix16_En16
  CONSTANT coeff256                       : signed(15 DOWNTO 0) := to_signed(-37, 16); -- sfix16_En16
  CONSTANT coeff257                       : signed(15 DOWNTO 0) := to_signed(70, 16); -- sfix16_En16
  CONSTANT coeff258                       : signed(15 DOWNTO 0) := to_signed(130, 16); -- sfix16_En16
  CONSTANT coeff259                       : signed(15 DOWNTO 0) := to_signed(108, 16); -- sfix16_En16
  CONSTANT coeff260                       : signed(15 DOWNTO 0) := to_signed(22, 16); -- sfix16_En16
  CONSTANT coeff261                       : signed(15 DOWNTO 0) := to_signed(-73, 16); -- sfix16_En16
  CONSTANT coeff262                       : signed(15 DOWNTO 0) := to_signed(-119, 16); -- sfix16_En16
  CONSTANT coeff263                       : signed(15 DOWNTO 0) := to_signed(-91, 16); -- sfix16_En16
  CONSTANT coeff264                       : signed(15 DOWNTO 0) := to_signed(-10, 16); -- sfix16_En16
  CONSTANT coeff265                       : signed(15 DOWNTO 0) := to_signed(73, 16); -- sfix16_En16
  CONSTANT coeff266                       : signed(15 DOWNTO 0) := to_signed(108, 16); -- sfix16_En16
  CONSTANT coeff267                       : signed(15 DOWNTO 0) := to_signed(75, 16); -- sfix16_En16
  CONSTANT coeff268                       : signed(15 DOWNTO 0) := to_signed(-1, 16); -- sfix16_En16
  CONSTANT coeff269                       : signed(15 DOWNTO 0) := to_signed(-72, 16); -- sfix16_En16
  CONSTANT coeff270                       : signed(15 DOWNTO 0) := to_signed(-97, 16); -- sfix16_En16
  CONSTANT coeff271                       : signed(15 DOWNTO 0) := to_signed(-62, 16); -- sfix16_En16
  CONSTANT coeff272                       : signed(15 DOWNTO 0) := to_signed(9, 16); -- sfix16_En16
  CONSTANT coeff273                       : signed(15 DOWNTO 0) := to_signed(70, 16); -- sfix16_En16
  CONSTANT coeff274                       : signed(15 DOWNTO 0) := to_signed(86, 16); -- sfix16_En16
  CONSTANT coeff275                       : signed(15 DOWNTO 0) := to_signed(49, 16); -- sfix16_En16
  CONSTANT coeff276                       : signed(15 DOWNTO 0) := to_signed(-15, 16); -- sfix16_En16
  CONSTANT coeff277                       : signed(15 DOWNTO 0) := to_signed(-67, 16); -- sfix16_En16
  CONSTANT coeff278                       : signed(15 DOWNTO 0) := to_signed(-76, 16); -- sfix16_En16
  CONSTANT coeff279                       : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En16
  CONSTANT coeff280                       : signed(15 DOWNTO 0) := to_signed(20, 16); -- sfix16_En16
  CONSTANT coeff281                       : signed(15 DOWNTO 0) := to_signed(63, 16); -- sfix16_En16
  CONSTANT coeff282                       : signed(15 DOWNTO 0) := to_signed(66, 16); -- sfix16_En16
  CONSTANT coeff283                       : signed(15 DOWNTO 0) := to_signed(29, 16); -- sfix16_En16
  CONSTANT coeff284                       : signed(15 DOWNTO 0) := to_signed(-23, 16); -- sfix16_En16
  CONSTANT coeff285                       : signed(15 DOWNTO 0) := to_signed(-59, 16); -- sfix16_En16
  CONSTANT coeff286                       : signed(15 DOWNTO 0) := to_signed(-57, 16); -- sfix16_En16
  CONSTANT coeff287                       : signed(15 DOWNTO 0) := to_signed(-21, 16); -- sfix16_En16
  CONSTANT coeff288                       : signed(15 DOWNTO 0) := to_signed(25, 16); -- sfix16_En16
  CONSTANT coeff289                       : signed(15 DOWNTO 0) := to_signed(54, 16); -- sfix16_En16
  CONSTANT coeff290                       : signed(15 DOWNTO 0) := to_signed(49, 16); -- sfix16_En16
  CONSTANT coeff291                       : signed(15 DOWNTO 0) := to_signed(15, 16); -- sfix16_En16
  CONSTANT coeff292                       : signed(15 DOWNTO 0) := to_signed(-26, 16); -- sfix16_En16
  CONSTANT coeff293                       : signed(15 DOWNTO 0) := to_signed(-49, 16); -- sfix16_En16
  CONSTANT coeff294                       : signed(15 DOWNTO 0) := to_signed(-41, 16); -- sfix16_En16
  CONSTANT coeff295                       : signed(15 DOWNTO 0) := to_signed(-9, 16); -- sfix16_En16
  CONSTANT coeff296                       : signed(15 DOWNTO 0) := to_signed(26, 16); -- sfix16_En16
  CONSTANT coeff297                       : signed(15 DOWNTO 0) := to_signed(44, 16); -- sfix16_En16
  CONSTANT coeff298                       : signed(15 DOWNTO 0) := to_signed(34, 16); -- sfix16_En16
  CONSTANT coeff299                       : signed(15 DOWNTO 0) := to_signed(5, 16); -- sfix16_En16
  CONSTANT coeff300                       : signed(15 DOWNTO 0) := to_signed(-26, 16); -- sfix16_En16
  CONSTANT coeff301                       : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En16
  CONSTANT coeff302                       : signed(15 DOWNTO 0) := to_signed(-29, 16); -- sfix16_En16
  CONSTANT coeff303                       : signed(15 DOWNTO 0) := to_signed(-2, 16); -- sfix16_En16
  CONSTANT coeff304                       : signed(15 DOWNTO 0) := to_signed(24, 16); -- sfix16_En16
  CONSTANT coeff305                       : signed(15 DOWNTO 0) := to_signed(34, 16); -- sfix16_En16
  CONSTANT coeff306                       : signed(15 DOWNTO 0) := to_signed(23, 16); -- sfix16_En16
  CONSTANT coeff307                       : signed(15 DOWNTO 0) := to_signed(-2, 16); -- sfix16_En16
  CONSTANT coeff308                       : signed(15 DOWNTO 0) := to_signed(-24, 16); -- sfix16_En16
  CONSTANT coeff309                       : signed(15 DOWNTO 0) := to_signed(-31, 16); -- sfix16_En16
  CONSTANT coeff310                       : signed(15 DOWNTO 0) := to_signed(-19, 16); -- sfix16_En16
  CONSTANT coeff311                       : signed(15 DOWNTO 0) := to_signed(2, 16); -- sfix16_En16
  CONSTANT coeff312                       : signed(15 DOWNTO 0) := to_signed(21, 16); -- sfix16_En16
  CONSTANT coeff313                       : signed(15 DOWNTO 0) := to_signed(25, 16); -- sfix16_En16
  CONSTANT coeff314                       : signed(15 DOWNTO 0) := to_signed(14, 16); -- sfix16_En16
  CONSTANT coeff315                       : signed(15 DOWNTO 0) := to_signed(-6, 16); -- sfix16_En16
  CONSTANT coeff316                       : signed(15 DOWNTO 0) := to_signed(-22, 16); -- sfix16_En16
  CONSTANT coeff317                       : signed(15 DOWNTO 0) := to_signed(-25, 16); -- sfix16_En16
  CONSTANT coeff318                       : signed(15 DOWNTO 0) := to_signed(-14, 16); -- sfix16_En16
  CONSTANT coeff319                       : signed(15 DOWNTO 0) := to_signed(3, 16); -- sfix16_En16
  CONSTANT coeff320                       : signed(15 DOWNTO 0) := to_signed(16, 16); -- sfix16_En16
  CONSTANT coeff321                       : signed(15 DOWNTO 0) := to_signed(16, 16); -- sfix16_En16
  CONSTANT coeff322                       : signed(15 DOWNTO 0) := to_signed(5, 16); -- sfix16_En16
  CONSTANT coeff323                       : signed(15 DOWNTO 0) := to_signed(-12, 16); -- sfix16_En16
  CONSTANT coeff324                       : signed(15 DOWNTO 0) := to_signed(-24, 16); -- sfix16_En16
  CONSTANT coeff325                       : signed(15 DOWNTO 0) := to_signed(-25, 16); -- sfix16_En16
  CONSTANT coeff326                       : signed(15 DOWNTO 0) := to_signed(-15, 16); -- sfix16_En16
  CONSTANT coeff327                       : signed(15 DOWNTO 0) := to_signed(-1, 16); -- sfix16_En16
  CONSTANT coeff328                       : signed(15 DOWNTO 0) := to_signed(8, 16); -- sfix16_En16
  CONSTANT coeff329                       : signed(15 DOWNTO 0) := to_signed(5, 16); -- sfix16_En16
  CONSTANT coeff330                       : signed(15 DOWNTO 0) := to_signed(-8, 16); -- sfix16_En16
  CONSTANT coeff331                       : signed(15 DOWNTO 0) := to_signed(-27, 16); -- sfix16_En16
  CONSTANT coeff332                       : signed(15 DOWNTO 0) := to_signed(-43, 16); -- sfix16_En16
  CONSTANT coeff333                       : signed(15 DOWNTO 0) := to_signed(-47, 16); -- sfix16_En16
  CONSTANT coeff334                       : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En16
  CONSTANT coeff335                       : signed(15 DOWNTO 0) := to_signed(-21, 16); -- sfix16_En16
  CONSTANT coeff336                       : signed(15 DOWNTO 0) := to_signed(-1, 16); -- sfix16_En16
  CONSTANT coeff337                       : signed(15 DOWNTO 0) := to_signed(15, 16); -- sfix16_En16
  CONSTANT coeff338                       : signed(15 DOWNTO 0) := to_signed(22, 16); -- sfix16_En16
  CONSTANT coeff339                       : signed(15 DOWNTO 0) := to_signed(21, 16); -- sfix16_En16
  CONSTANT coeff340                       : signed(15 DOWNTO 0) := to_signed(15, 16); -- sfix16_En16
  CONSTANT coeff341                       : signed(15 DOWNTO 0) := to_signed(8, 16); -- sfix16_En16

  -- Signals
  SIGNAL cur_count                        : unsigned(8 DOWNTO 0); -- ufix9
  SIGNAL phase_0                          : std_logic; -- boolean
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 340); -- sfix32_En31
  SIGNAL I_FILTER_regtype                 : signed(31 DOWNTO 0); -- sfix32_En31
  SIGNAL inputmux_1                       : signed(31 DOWNTO 0); -- sfix32_En31
  SIGNAL acc_final                        : signed(49 DOWNTO 0); -- sfix50_En47
  SIGNAL acc_out_1                        : signed(49 DOWNTO 0); -- sfix50_En47
  SIGNAL product_1                        : signed(46 DOWNTO 0); -- sfix47_En47
  SIGNAL product_1_mux                    : signed(15 DOWNTO 0); -- sfix16_En16
  SIGNAL mul_temp                         : signed(47 DOWNTO 0); -- sfix48_En47
  SIGNAL prod_typeconvert_1               : signed(49 DOWNTO 0); -- sfix50_En47
  SIGNAL acc_sum_1                        : signed(49 DOWNTO 0); -- sfix50_En47
  SIGNAL acc_in_1                         : signed(49 DOWNTO 0); -- sfix50_En47
  SIGNAL add_temp                         : signed(50 DOWNTO 0); -- sfix51_En47
  SIGNAL output_typeconvert               : signed(49 DOWNTO 0); -- sfix50_En47
  SIGNAL output_register                  : signed(49 DOWNTO 0); -- sfix50_En47


BEGIN

  -- Block Statements
  Counter_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      cur_count <= to_unsigned(0, 9);
    ELSIF rising_edge(I_CLK) THEN
      IF cur_count >= to_unsigned(340, 9) THEN
        cur_count <= to_unsigned(0, 9);
      ELSE
        cur_count <= cur_count + to_unsigned(1, 9);
      END IF;
    END IF; 
  END PROCESS Counter_process;

  phase_0 <= '1' WHEN cur_count = to_unsigned(0, 9) ELSE '0';

  Delay_Pipeline_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      delay_pipeline(0 TO 340) <= (OTHERS => (OTHERS => '0'));
    ELSIF rising_edge(I_CLK) THEN
      IF phase_0 = '1' THEN
        delay_pipeline(0) <= signed(I_FILTER);
        delay_pipeline(1 TO 340) <= delay_pipeline(0 TO 339);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;

  I_FILTER_regtype <= signed(I_FILTER);

  inputmux_1 <= I_FILTER_regtype WHEN ( cur_count = to_unsigned(0, 9) ) ELSE
                     delay_pipeline(1) WHEN ( cur_count = to_unsigned(1, 9) ) ELSE
                     delay_pipeline(2) WHEN ( cur_count = to_unsigned(2, 9) ) ELSE
                     delay_pipeline(3) WHEN ( cur_count = to_unsigned(3, 9) ) ELSE
                     delay_pipeline(4) WHEN ( cur_count = to_unsigned(4, 9) ) ELSE
                     delay_pipeline(5) WHEN ( cur_count = to_unsigned(5, 9) ) ELSE
                     delay_pipeline(6) WHEN ( cur_count = to_unsigned(6, 9) ) ELSE
                     delay_pipeline(7) WHEN ( cur_count = to_unsigned(7, 9) ) ELSE
                     delay_pipeline(8) WHEN ( cur_count = to_unsigned(8, 9) ) ELSE
                     delay_pipeline(9) WHEN ( cur_count = to_unsigned(9, 9) ) ELSE
                     delay_pipeline(10) WHEN ( cur_count = to_unsigned(10, 9) ) ELSE
                     delay_pipeline(11) WHEN ( cur_count = to_unsigned(11, 9) ) ELSE
                     delay_pipeline(12) WHEN ( cur_count = to_unsigned(12, 9) ) ELSE
                     delay_pipeline(13) WHEN ( cur_count = to_unsigned(13, 9) ) ELSE
                     delay_pipeline(14) WHEN ( cur_count = to_unsigned(14, 9) ) ELSE
                     delay_pipeline(15) WHEN ( cur_count = to_unsigned(15, 9) ) ELSE
                     delay_pipeline(16) WHEN ( cur_count = to_unsigned(16, 9) ) ELSE
                     delay_pipeline(17) WHEN ( cur_count = to_unsigned(17, 9) ) ELSE
                     delay_pipeline(18) WHEN ( cur_count = to_unsigned(18, 9) ) ELSE
                     delay_pipeline(19) WHEN ( cur_count = to_unsigned(19, 9) ) ELSE
                     delay_pipeline(20) WHEN ( cur_count = to_unsigned(20, 9) ) ELSE
                     delay_pipeline(21) WHEN ( cur_count = to_unsigned(21, 9) ) ELSE
                     delay_pipeline(22) WHEN ( cur_count = to_unsigned(22, 9) ) ELSE
                     delay_pipeline(23) WHEN ( cur_count = to_unsigned(23, 9) ) ELSE
                     delay_pipeline(24) WHEN ( cur_count = to_unsigned(24, 9) ) ELSE
                     delay_pipeline(25) WHEN ( cur_count = to_unsigned(25, 9) ) ELSE
                     delay_pipeline(26) WHEN ( cur_count = to_unsigned(26, 9) ) ELSE
                     delay_pipeline(27) WHEN ( cur_count = to_unsigned(27, 9) ) ELSE
                     delay_pipeline(28) WHEN ( cur_count = to_unsigned(28, 9) ) ELSE
                     delay_pipeline(29) WHEN ( cur_count = to_unsigned(29, 9) ) ELSE
                     delay_pipeline(30) WHEN ( cur_count = to_unsigned(30, 9) ) ELSE
                     delay_pipeline(31) WHEN ( cur_count = to_unsigned(31, 9) ) ELSE
                     delay_pipeline(32) WHEN ( cur_count = to_unsigned(32, 9) ) ELSE
                     delay_pipeline(33) WHEN ( cur_count = to_unsigned(33, 9) ) ELSE
                     delay_pipeline(34) WHEN ( cur_count = to_unsigned(34, 9) ) ELSE
                     delay_pipeline(35) WHEN ( cur_count = to_unsigned(35, 9) ) ELSE
                     delay_pipeline(36) WHEN ( cur_count = to_unsigned(36, 9) ) ELSE
                     delay_pipeline(37) WHEN ( cur_count = to_unsigned(37, 9) ) ELSE
                     delay_pipeline(38) WHEN ( cur_count = to_unsigned(38, 9) ) ELSE
                     delay_pipeline(39) WHEN ( cur_count = to_unsigned(39, 9) ) ELSE
                     delay_pipeline(40) WHEN ( cur_count = to_unsigned(40, 9) ) ELSE
                     delay_pipeline(41) WHEN ( cur_count = to_unsigned(41, 9) ) ELSE
                     delay_pipeline(42) WHEN ( cur_count = to_unsigned(42, 9) ) ELSE
                     delay_pipeline(43) WHEN ( cur_count = to_unsigned(43, 9) ) ELSE
                     delay_pipeline(44) WHEN ( cur_count = to_unsigned(44, 9) ) ELSE
                     delay_pipeline(45) WHEN ( cur_count = to_unsigned(45, 9) ) ELSE
                     delay_pipeline(46) WHEN ( cur_count = to_unsigned(46, 9) ) ELSE
                     delay_pipeline(47) WHEN ( cur_count = to_unsigned(47, 9) ) ELSE
                     delay_pipeline(48) WHEN ( cur_count = to_unsigned(48, 9) ) ELSE
                     delay_pipeline(49) WHEN ( cur_count = to_unsigned(49, 9) ) ELSE
                     delay_pipeline(50) WHEN ( cur_count = to_unsigned(50, 9) ) ELSE
                     delay_pipeline(51) WHEN ( cur_count = to_unsigned(51, 9) ) ELSE
                     delay_pipeline(52) WHEN ( cur_count = to_unsigned(52, 9) ) ELSE
                     delay_pipeline(53) WHEN ( cur_count = to_unsigned(53, 9) ) ELSE
                     delay_pipeline(54) WHEN ( cur_count = to_unsigned(54, 9) ) ELSE
                     delay_pipeline(55) WHEN ( cur_count = to_unsigned(55, 9) ) ELSE
                     delay_pipeline(56) WHEN ( cur_count = to_unsigned(56, 9) ) ELSE
                     delay_pipeline(57) WHEN ( cur_count = to_unsigned(57, 9) ) ELSE
                     delay_pipeline(58) WHEN ( cur_count = to_unsigned(58, 9) ) ELSE
                     delay_pipeline(59) WHEN ( cur_count = to_unsigned(59, 9) ) ELSE
                     delay_pipeline(60) WHEN ( cur_count = to_unsigned(60, 9) ) ELSE
                     delay_pipeline(61) WHEN ( cur_count = to_unsigned(61, 9) ) ELSE
                     delay_pipeline(62) WHEN ( cur_count = to_unsigned(62, 9) ) ELSE
                     delay_pipeline(63) WHEN ( cur_count = to_unsigned(63, 9) ) ELSE
                     delay_pipeline(64) WHEN ( cur_count = to_unsigned(64, 9) ) ELSE
                     delay_pipeline(65) WHEN ( cur_count = to_unsigned(65, 9) ) ELSE
                     delay_pipeline(66) WHEN ( cur_count = to_unsigned(66, 9) ) ELSE
                     delay_pipeline(67) WHEN ( cur_count = to_unsigned(67, 9) ) ELSE
                     delay_pipeline(68) WHEN ( cur_count = to_unsigned(68, 9) ) ELSE
                     delay_pipeline(69) WHEN ( cur_count = to_unsigned(69, 9) ) ELSE
                     delay_pipeline(70) WHEN ( cur_count = to_unsigned(70, 9) ) ELSE
                     delay_pipeline(71) WHEN ( cur_count = to_unsigned(71, 9) ) ELSE
                     delay_pipeline(72) WHEN ( cur_count = to_unsigned(72, 9) ) ELSE
                     delay_pipeline(73) WHEN ( cur_count = to_unsigned(73, 9) ) ELSE
                     delay_pipeline(74) WHEN ( cur_count = to_unsigned(74, 9) ) ELSE
                     delay_pipeline(75) WHEN ( cur_count = to_unsigned(75, 9) ) ELSE
                     delay_pipeline(76) WHEN ( cur_count = to_unsigned(76, 9) ) ELSE
                     delay_pipeline(77) WHEN ( cur_count = to_unsigned(77, 9) ) ELSE
                     delay_pipeline(78) WHEN ( cur_count = to_unsigned(78, 9) ) ELSE
                     delay_pipeline(79) WHEN ( cur_count = to_unsigned(79, 9) ) ELSE
                     delay_pipeline(80) WHEN ( cur_count = to_unsigned(80, 9) ) ELSE
                     delay_pipeline(81) WHEN ( cur_count = to_unsigned(81, 9) ) ELSE
                     delay_pipeline(82) WHEN ( cur_count = to_unsigned(82, 9) ) ELSE
                     delay_pipeline(83) WHEN ( cur_count = to_unsigned(83, 9) ) ELSE
                     delay_pipeline(84) WHEN ( cur_count = to_unsigned(84, 9) ) ELSE
                     delay_pipeline(85) WHEN ( cur_count = to_unsigned(85, 9) ) ELSE
                     delay_pipeline(86) WHEN ( cur_count = to_unsigned(86, 9) ) ELSE
                     delay_pipeline(87) WHEN ( cur_count = to_unsigned(87, 9) ) ELSE
                     delay_pipeline(88) WHEN ( cur_count = to_unsigned(88, 9) ) ELSE
                     delay_pipeline(89) WHEN ( cur_count = to_unsigned(89, 9) ) ELSE
                     delay_pipeline(90) WHEN ( cur_count = to_unsigned(90, 9) ) ELSE
                     delay_pipeline(91) WHEN ( cur_count = to_unsigned(91, 9) ) ELSE
                     delay_pipeline(92) WHEN ( cur_count = to_unsigned(92, 9) ) ELSE
                     delay_pipeline(93) WHEN ( cur_count = to_unsigned(93, 9) ) ELSE
                     delay_pipeline(94) WHEN ( cur_count = to_unsigned(94, 9) ) ELSE
                     delay_pipeline(95) WHEN ( cur_count = to_unsigned(95, 9) ) ELSE
                     delay_pipeline(96) WHEN ( cur_count = to_unsigned(96, 9) ) ELSE
                     delay_pipeline(97) WHEN ( cur_count = to_unsigned(97, 9) ) ELSE
                     delay_pipeline(98) WHEN ( cur_count = to_unsigned(98, 9) ) ELSE
                     delay_pipeline(99) WHEN ( cur_count = to_unsigned(99, 9) ) ELSE
                     delay_pipeline(100) WHEN ( cur_count = to_unsigned(100, 9) ) ELSE
                     delay_pipeline(101) WHEN ( cur_count = to_unsigned(101, 9) ) ELSE
                     delay_pipeline(102) WHEN ( cur_count = to_unsigned(102, 9) ) ELSE
                     delay_pipeline(103) WHEN ( cur_count = to_unsigned(103, 9) ) ELSE
                     delay_pipeline(104) WHEN ( cur_count = to_unsigned(104, 9) ) ELSE
                     delay_pipeline(105) WHEN ( cur_count = to_unsigned(105, 9) ) ELSE
                     delay_pipeline(106) WHEN ( cur_count = to_unsigned(106, 9) ) ELSE
                     delay_pipeline(107) WHEN ( cur_count = to_unsigned(107, 9) ) ELSE
                     delay_pipeline(108) WHEN ( cur_count = to_unsigned(108, 9) ) ELSE
                     delay_pipeline(109) WHEN ( cur_count = to_unsigned(109, 9) ) ELSE
                     delay_pipeline(110) WHEN ( cur_count = to_unsigned(110, 9) ) ELSE
                     delay_pipeline(111) WHEN ( cur_count = to_unsigned(111, 9) ) ELSE
                     delay_pipeline(112) WHEN ( cur_count = to_unsigned(112, 9) ) ELSE
                     delay_pipeline(113) WHEN ( cur_count = to_unsigned(113, 9) ) ELSE
                     delay_pipeline(114) WHEN ( cur_count = to_unsigned(114, 9) ) ELSE
                     delay_pipeline(115) WHEN ( cur_count = to_unsigned(115, 9) ) ELSE
                     delay_pipeline(116) WHEN ( cur_count = to_unsigned(116, 9) ) ELSE
                     delay_pipeline(117) WHEN ( cur_count = to_unsigned(117, 9) ) ELSE
                     delay_pipeline(118) WHEN ( cur_count = to_unsigned(118, 9) ) ELSE
                     delay_pipeline(119) WHEN ( cur_count = to_unsigned(119, 9) ) ELSE
                     delay_pipeline(120) WHEN ( cur_count = to_unsigned(120, 9) ) ELSE
                     delay_pipeline(121) WHEN ( cur_count = to_unsigned(121, 9) ) ELSE
                     delay_pipeline(122) WHEN ( cur_count = to_unsigned(122, 9) ) ELSE
                     delay_pipeline(123) WHEN ( cur_count = to_unsigned(123, 9) ) ELSE
                     delay_pipeline(124) WHEN ( cur_count = to_unsigned(124, 9) ) ELSE
                     delay_pipeline(125) WHEN ( cur_count = to_unsigned(125, 9) ) ELSE
                     delay_pipeline(126) WHEN ( cur_count = to_unsigned(126, 9) ) ELSE
                     delay_pipeline(127) WHEN ( cur_count = to_unsigned(127, 9) ) ELSE
                     delay_pipeline(128) WHEN ( cur_count = to_unsigned(128, 9) ) ELSE
                     delay_pipeline(129) WHEN ( cur_count = to_unsigned(129, 9) ) ELSE
                     delay_pipeline(130) WHEN ( cur_count = to_unsigned(130, 9) ) ELSE
                     delay_pipeline(131) WHEN ( cur_count = to_unsigned(131, 9) ) ELSE
                     delay_pipeline(132) WHEN ( cur_count = to_unsigned(132, 9) ) ELSE
                     delay_pipeline(133) WHEN ( cur_count = to_unsigned(133, 9) ) ELSE
                     delay_pipeline(134) WHEN ( cur_count = to_unsigned(134, 9) ) ELSE
                     delay_pipeline(135) WHEN ( cur_count = to_unsigned(135, 9) ) ELSE
                     delay_pipeline(136) WHEN ( cur_count = to_unsigned(136, 9) ) ELSE
                     delay_pipeline(137) WHEN ( cur_count = to_unsigned(137, 9) ) ELSE
                     delay_pipeline(138) WHEN ( cur_count = to_unsigned(138, 9) ) ELSE
                     delay_pipeline(139) WHEN ( cur_count = to_unsigned(139, 9) ) ELSE
                     delay_pipeline(140) WHEN ( cur_count = to_unsigned(140, 9) ) ELSE
                     delay_pipeline(141) WHEN ( cur_count = to_unsigned(141, 9) ) ELSE
                     delay_pipeline(142) WHEN ( cur_count = to_unsigned(142, 9) ) ELSE
                     delay_pipeline(143) WHEN ( cur_count = to_unsigned(143, 9) ) ELSE
                     delay_pipeline(144) WHEN ( cur_count = to_unsigned(144, 9) ) ELSE
                     delay_pipeline(145) WHEN ( cur_count = to_unsigned(145, 9) ) ELSE
                     delay_pipeline(146) WHEN ( cur_count = to_unsigned(146, 9) ) ELSE
                     delay_pipeline(147) WHEN ( cur_count = to_unsigned(147, 9) ) ELSE
                     delay_pipeline(148) WHEN ( cur_count = to_unsigned(148, 9) ) ELSE
                     delay_pipeline(149) WHEN ( cur_count = to_unsigned(149, 9) ) ELSE
                     delay_pipeline(150) WHEN ( cur_count = to_unsigned(150, 9) ) ELSE
                     delay_pipeline(151) WHEN ( cur_count = to_unsigned(151, 9) ) ELSE
                     delay_pipeline(152) WHEN ( cur_count = to_unsigned(152, 9) ) ELSE
                     delay_pipeline(153) WHEN ( cur_count = to_unsigned(153, 9) ) ELSE
                     delay_pipeline(154) WHEN ( cur_count = to_unsigned(154, 9) ) ELSE
                     delay_pipeline(155) WHEN ( cur_count = to_unsigned(155, 9) ) ELSE
                     delay_pipeline(156) WHEN ( cur_count = to_unsigned(156, 9) ) ELSE
                     delay_pipeline(157) WHEN ( cur_count = to_unsigned(157, 9) ) ELSE
                     delay_pipeline(158) WHEN ( cur_count = to_unsigned(158, 9) ) ELSE
                     delay_pipeline(159) WHEN ( cur_count = to_unsigned(159, 9) ) ELSE
                     delay_pipeline(160) WHEN ( cur_count = to_unsigned(160, 9) ) ELSE
                     delay_pipeline(161) WHEN ( cur_count = to_unsigned(161, 9) ) ELSE
                     delay_pipeline(162) WHEN ( cur_count = to_unsigned(162, 9) ) ELSE
                     delay_pipeline(163) WHEN ( cur_count = to_unsigned(163, 9) ) ELSE
                     delay_pipeline(164) WHEN ( cur_count = to_unsigned(164, 9) ) ELSE
                     delay_pipeline(165) WHEN ( cur_count = to_unsigned(165, 9) ) ELSE
                     delay_pipeline(166) WHEN ( cur_count = to_unsigned(166, 9) ) ELSE
                     delay_pipeline(167) WHEN ( cur_count = to_unsigned(167, 9) ) ELSE
                     delay_pipeline(168) WHEN ( cur_count = to_unsigned(168, 9) ) ELSE
                     delay_pipeline(169) WHEN ( cur_count = to_unsigned(169, 9) ) ELSE
                     delay_pipeline(170) WHEN ( cur_count = to_unsigned(170, 9) ) ELSE
                     delay_pipeline(171) WHEN ( cur_count = to_unsigned(171, 9) ) ELSE
                     delay_pipeline(172) WHEN ( cur_count = to_unsigned(172, 9) ) ELSE
                     delay_pipeline(173) WHEN ( cur_count = to_unsigned(173, 9) ) ELSE
                     delay_pipeline(174) WHEN ( cur_count = to_unsigned(174, 9) ) ELSE
                     delay_pipeline(175) WHEN ( cur_count = to_unsigned(175, 9) ) ELSE
                     delay_pipeline(176) WHEN ( cur_count = to_unsigned(176, 9) ) ELSE
                     delay_pipeline(177) WHEN ( cur_count = to_unsigned(177, 9) ) ELSE
                     delay_pipeline(178) WHEN ( cur_count = to_unsigned(178, 9) ) ELSE
                     delay_pipeline(179) WHEN ( cur_count = to_unsigned(179, 9) ) ELSE
                     delay_pipeline(180) WHEN ( cur_count = to_unsigned(180, 9) ) ELSE
                     delay_pipeline(181) WHEN ( cur_count = to_unsigned(181, 9) ) ELSE
                     delay_pipeline(182) WHEN ( cur_count = to_unsigned(182, 9) ) ELSE
                     delay_pipeline(183) WHEN ( cur_count = to_unsigned(183, 9) ) ELSE
                     delay_pipeline(184) WHEN ( cur_count = to_unsigned(184, 9) ) ELSE
                     delay_pipeline(185) WHEN ( cur_count = to_unsigned(185, 9) ) ELSE
                     delay_pipeline(186) WHEN ( cur_count = to_unsigned(186, 9) ) ELSE
                     delay_pipeline(187) WHEN ( cur_count = to_unsigned(187, 9) ) ELSE
                     delay_pipeline(188) WHEN ( cur_count = to_unsigned(188, 9) ) ELSE
                     delay_pipeline(189) WHEN ( cur_count = to_unsigned(189, 9) ) ELSE
                     delay_pipeline(190) WHEN ( cur_count = to_unsigned(190, 9) ) ELSE
                     delay_pipeline(191) WHEN ( cur_count = to_unsigned(191, 9) ) ELSE
                     delay_pipeline(192) WHEN ( cur_count = to_unsigned(192, 9) ) ELSE
                     delay_pipeline(193) WHEN ( cur_count = to_unsigned(193, 9) ) ELSE
                     delay_pipeline(194) WHEN ( cur_count = to_unsigned(194, 9) ) ELSE
                     delay_pipeline(195) WHEN ( cur_count = to_unsigned(195, 9) ) ELSE
                     delay_pipeline(196) WHEN ( cur_count = to_unsigned(196, 9) ) ELSE
                     delay_pipeline(197) WHEN ( cur_count = to_unsigned(197, 9) ) ELSE
                     delay_pipeline(198) WHEN ( cur_count = to_unsigned(198, 9) ) ELSE
                     delay_pipeline(199) WHEN ( cur_count = to_unsigned(199, 9) ) ELSE
                     delay_pipeline(200) WHEN ( cur_count = to_unsigned(200, 9) ) ELSE
                     delay_pipeline(201) WHEN ( cur_count = to_unsigned(201, 9) ) ELSE
                     delay_pipeline(202) WHEN ( cur_count = to_unsigned(202, 9) ) ELSE
                     delay_pipeline(203) WHEN ( cur_count = to_unsigned(203, 9) ) ELSE
                     delay_pipeline(204) WHEN ( cur_count = to_unsigned(204, 9) ) ELSE
                     delay_pipeline(205) WHEN ( cur_count = to_unsigned(205, 9) ) ELSE
                     delay_pipeline(206) WHEN ( cur_count = to_unsigned(206, 9) ) ELSE
                     delay_pipeline(207) WHEN ( cur_count = to_unsigned(207, 9) ) ELSE
                     delay_pipeline(208) WHEN ( cur_count = to_unsigned(208, 9) ) ELSE
                     delay_pipeline(209) WHEN ( cur_count = to_unsigned(209, 9) ) ELSE
                     delay_pipeline(210) WHEN ( cur_count = to_unsigned(210, 9) ) ELSE
                     delay_pipeline(211) WHEN ( cur_count = to_unsigned(211, 9) ) ELSE
                     delay_pipeline(212) WHEN ( cur_count = to_unsigned(212, 9) ) ELSE
                     delay_pipeline(213) WHEN ( cur_count = to_unsigned(213, 9) ) ELSE
                     delay_pipeline(214) WHEN ( cur_count = to_unsigned(214, 9) ) ELSE
                     delay_pipeline(215) WHEN ( cur_count = to_unsigned(215, 9) ) ELSE
                     delay_pipeline(216) WHEN ( cur_count = to_unsigned(216, 9) ) ELSE
                     delay_pipeline(217) WHEN ( cur_count = to_unsigned(217, 9) ) ELSE
                     delay_pipeline(218) WHEN ( cur_count = to_unsigned(218, 9) ) ELSE
                     delay_pipeline(219) WHEN ( cur_count = to_unsigned(219, 9) ) ELSE
                     delay_pipeline(220) WHEN ( cur_count = to_unsigned(220, 9) ) ELSE
                     delay_pipeline(221) WHEN ( cur_count = to_unsigned(221, 9) ) ELSE
                     delay_pipeline(222) WHEN ( cur_count = to_unsigned(222, 9) ) ELSE
                     delay_pipeline(223) WHEN ( cur_count = to_unsigned(223, 9) ) ELSE
                     delay_pipeline(224) WHEN ( cur_count = to_unsigned(224, 9) ) ELSE
                     delay_pipeline(225) WHEN ( cur_count = to_unsigned(225, 9) ) ELSE
                     delay_pipeline(226) WHEN ( cur_count = to_unsigned(226, 9) ) ELSE
                     delay_pipeline(227) WHEN ( cur_count = to_unsigned(227, 9) ) ELSE
                     delay_pipeline(228) WHEN ( cur_count = to_unsigned(228, 9) ) ELSE
                     delay_pipeline(229) WHEN ( cur_count = to_unsigned(229, 9) ) ELSE
                     delay_pipeline(230) WHEN ( cur_count = to_unsigned(230, 9) ) ELSE
                     delay_pipeline(231) WHEN ( cur_count = to_unsigned(231, 9) ) ELSE
                     delay_pipeline(232) WHEN ( cur_count = to_unsigned(232, 9) ) ELSE
                     delay_pipeline(233) WHEN ( cur_count = to_unsigned(233, 9) ) ELSE
                     delay_pipeline(234) WHEN ( cur_count = to_unsigned(234, 9) ) ELSE
                     delay_pipeline(235) WHEN ( cur_count = to_unsigned(235, 9) ) ELSE
                     delay_pipeline(236) WHEN ( cur_count = to_unsigned(236, 9) ) ELSE
                     delay_pipeline(237) WHEN ( cur_count = to_unsigned(237, 9) ) ELSE
                     delay_pipeline(238) WHEN ( cur_count = to_unsigned(238, 9) ) ELSE
                     delay_pipeline(239) WHEN ( cur_count = to_unsigned(239, 9) ) ELSE
                     delay_pipeline(240) WHEN ( cur_count = to_unsigned(240, 9) ) ELSE
                     delay_pipeline(241) WHEN ( cur_count = to_unsigned(241, 9) ) ELSE
                     delay_pipeline(242) WHEN ( cur_count = to_unsigned(242, 9) ) ELSE
                     delay_pipeline(243) WHEN ( cur_count = to_unsigned(243, 9) ) ELSE
                     delay_pipeline(244) WHEN ( cur_count = to_unsigned(244, 9) ) ELSE
                     delay_pipeline(245) WHEN ( cur_count = to_unsigned(245, 9) ) ELSE
                     delay_pipeline(246) WHEN ( cur_count = to_unsigned(246, 9) ) ELSE
                     delay_pipeline(247) WHEN ( cur_count = to_unsigned(247, 9) ) ELSE
                     delay_pipeline(248) WHEN ( cur_count = to_unsigned(248, 9) ) ELSE
                     delay_pipeline(249) WHEN ( cur_count = to_unsigned(249, 9) ) ELSE
                     delay_pipeline(250) WHEN ( cur_count = to_unsigned(250, 9) ) ELSE
                     delay_pipeline(251) WHEN ( cur_count = to_unsigned(251, 9) ) ELSE
                     delay_pipeline(252) WHEN ( cur_count = to_unsigned(252, 9) ) ELSE
                     delay_pipeline(253) WHEN ( cur_count = to_unsigned(253, 9) ) ELSE
                     delay_pipeline(254) WHEN ( cur_count = to_unsigned(254, 9) ) ELSE
                     delay_pipeline(255) WHEN ( cur_count = to_unsigned(255, 9) ) ELSE
                     delay_pipeline(256) WHEN ( cur_count = to_unsigned(256, 9) ) ELSE
                     delay_pipeline(257) WHEN ( cur_count = to_unsigned(257, 9) ) ELSE
                     delay_pipeline(258) WHEN ( cur_count = to_unsigned(258, 9) ) ELSE
                     delay_pipeline(259) WHEN ( cur_count = to_unsigned(259, 9) ) ELSE
                     delay_pipeline(260) WHEN ( cur_count = to_unsigned(260, 9) ) ELSE
                     delay_pipeline(261) WHEN ( cur_count = to_unsigned(261, 9) ) ELSE
                     delay_pipeline(262) WHEN ( cur_count = to_unsigned(262, 9) ) ELSE
                     delay_pipeline(263) WHEN ( cur_count = to_unsigned(263, 9) ) ELSE
                     delay_pipeline(264) WHEN ( cur_count = to_unsigned(264, 9) ) ELSE
                     delay_pipeline(265) WHEN ( cur_count = to_unsigned(265, 9) ) ELSE
                     delay_pipeline(266) WHEN ( cur_count = to_unsigned(266, 9) ) ELSE
                     delay_pipeline(267) WHEN ( cur_count = to_unsigned(267, 9) ) ELSE
                     delay_pipeline(268) WHEN ( cur_count = to_unsigned(268, 9) ) ELSE
                     delay_pipeline(269) WHEN ( cur_count = to_unsigned(269, 9) ) ELSE
                     delay_pipeline(270) WHEN ( cur_count = to_unsigned(270, 9) ) ELSE
                     delay_pipeline(271) WHEN ( cur_count = to_unsigned(271, 9) ) ELSE
                     delay_pipeline(272) WHEN ( cur_count = to_unsigned(272, 9) ) ELSE
                     delay_pipeline(273) WHEN ( cur_count = to_unsigned(273, 9) ) ELSE
                     delay_pipeline(274) WHEN ( cur_count = to_unsigned(274, 9) ) ELSE
                     delay_pipeline(275) WHEN ( cur_count = to_unsigned(275, 9) ) ELSE
                     delay_pipeline(276) WHEN ( cur_count = to_unsigned(276, 9) ) ELSE
                     delay_pipeline(277) WHEN ( cur_count = to_unsigned(277, 9) ) ELSE
                     delay_pipeline(278) WHEN ( cur_count = to_unsigned(278, 9) ) ELSE
                     delay_pipeline(279) WHEN ( cur_count = to_unsigned(279, 9) ) ELSE
                     delay_pipeline(280) WHEN ( cur_count = to_unsigned(280, 9) ) ELSE
                     delay_pipeline(281) WHEN ( cur_count = to_unsigned(281, 9) ) ELSE
                     delay_pipeline(282) WHEN ( cur_count = to_unsigned(282, 9) ) ELSE
                     delay_pipeline(283) WHEN ( cur_count = to_unsigned(283, 9) ) ELSE
                     delay_pipeline(284) WHEN ( cur_count = to_unsigned(284, 9) ) ELSE
                     delay_pipeline(285) WHEN ( cur_count = to_unsigned(285, 9) ) ELSE
                     delay_pipeline(286) WHEN ( cur_count = to_unsigned(286, 9) ) ELSE
                     delay_pipeline(287) WHEN ( cur_count = to_unsigned(287, 9) ) ELSE
                     delay_pipeline(288) WHEN ( cur_count = to_unsigned(288, 9) ) ELSE
                     delay_pipeline(289) WHEN ( cur_count = to_unsigned(289, 9) ) ELSE
                     delay_pipeline(290) WHEN ( cur_count = to_unsigned(290, 9) ) ELSE
                     delay_pipeline(291) WHEN ( cur_count = to_unsigned(291, 9) ) ELSE
                     delay_pipeline(292) WHEN ( cur_count = to_unsigned(292, 9) ) ELSE
                     delay_pipeline(293) WHEN ( cur_count = to_unsigned(293, 9) ) ELSE
                     delay_pipeline(294) WHEN ( cur_count = to_unsigned(294, 9) ) ELSE
                     delay_pipeline(295) WHEN ( cur_count = to_unsigned(295, 9) ) ELSE
                     delay_pipeline(296) WHEN ( cur_count = to_unsigned(296, 9) ) ELSE
                     delay_pipeline(297) WHEN ( cur_count = to_unsigned(297, 9) ) ELSE
                     delay_pipeline(298) WHEN ( cur_count = to_unsigned(298, 9) ) ELSE
                     delay_pipeline(299) WHEN ( cur_count = to_unsigned(299, 9) ) ELSE
                     delay_pipeline(300) WHEN ( cur_count = to_unsigned(300, 9) ) ELSE
                     delay_pipeline(301) WHEN ( cur_count = to_unsigned(301, 9) ) ELSE
                     delay_pipeline(302) WHEN ( cur_count = to_unsigned(302, 9) ) ELSE
                     delay_pipeline(303) WHEN ( cur_count = to_unsigned(303, 9) ) ELSE
                     delay_pipeline(304) WHEN ( cur_count = to_unsigned(304, 9) ) ELSE
                     delay_pipeline(305) WHEN ( cur_count = to_unsigned(305, 9) ) ELSE
                     delay_pipeline(306) WHEN ( cur_count = to_unsigned(306, 9) ) ELSE
                     delay_pipeline(307) WHEN ( cur_count = to_unsigned(307, 9) ) ELSE
                     delay_pipeline(308) WHEN ( cur_count = to_unsigned(308, 9) ) ELSE
                     delay_pipeline(309) WHEN ( cur_count = to_unsigned(309, 9) ) ELSE
                     delay_pipeline(310) WHEN ( cur_count = to_unsigned(310, 9) ) ELSE
                     delay_pipeline(311) WHEN ( cur_count = to_unsigned(311, 9) ) ELSE
                     delay_pipeline(312) WHEN ( cur_count = to_unsigned(312, 9) ) ELSE
                     delay_pipeline(313) WHEN ( cur_count = to_unsigned(313, 9) ) ELSE
                     delay_pipeline(314) WHEN ( cur_count = to_unsigned(314, 9) ) ELSE
                     delay_pipeline(315) WHEN ( cur_count = to_unsigned(315, 9) ) ELSE
                     delay_pipeline(316) WHEN ( cur_count = to_unsigned(316, 9) ) ELSE
                     delay_pipeline(317) WHEN ( cur_count = to_unsigned(317, 9) ) ELSE
                     delay_pipeline(318) WHEN ( cur_count = to_unsigned(318, 9) ) ELSE
                     delay_pipeline(319) WHEN ( cur_count = to_unsigned(319, 9) ) ELSE
                     delay_pipeline(320) WHEN ( cur_count = to_unsigned(320, 9) ) ELSE
                     delay_pipeline(321) WHEN ( cur_count = to_unsigned(321, 9) ) ELSE
                     delay_pipeline(322) WHEN ( cur_count = to_unsigned(322, 9) ) ELSE
                     delay_pipeline(323) WHEN ( cur_count = to_unsigned(323, 9) ) ELSE
                     delay_pipeline(324) WHEN ( cur_count = to_unsigned(324, 9) ) ELSE
                     delay_pipeline(325) WHEN ( cur_count = to_unsigned(325, 9) ) ELSE
                     delay_pipeline(326) WHEN ( cur_count = to_unsigned(326, 9) ) ELSE
                     delay_pipeline(327) WHEN ( cur_count = to_unsigned(327, 9) ) ELSE
                     delay_pipeline(328) WHEN ( cur_count = to_unsigned(328, 9) ) ELSE
                     delay_pipeline(329) WHEN ( cur_count = to_unsigned(329, 9) ) ELSE
                     delay_pipeline(330) WHEN ( cur_count = to_unsigned(330, 9) ) ELSE
                     delay_pipeline(331) WHEN ( cur_count = to_unsigned(331, 9) ) ELSE
                     delay_pipeline(332) WHEN ( cur_count = to_unsigned(332, 9) ) ELSE
                     delay_pipeline(333) WHEN ( cur_count = to_unsigned(333, 9) ) ELSE
                     delay_pipeline(334) WHEN ( cur_count = to_unsigned(334, 9) ) ELSE
                     delay_pipeline(335) WHEN ( cur_count = to_unsigned(335, 9) ) ELSE
                     delay_pipeline(336) WHEN ( cur_count = to_unsigned(336, 9) ) ELSE
                     delay_pipeline(337) WHEN ( cur_count = to_unsigned(337, 9) ) ELSE
                     delay_pipeline(338) WHEN ( cur_count = to_unsigned(338, 9) ) ELSE
                     delay_pipeline(339) WHEN ( cur_count = to_unsigned(339, 9) ) ELSE
                     delay_pipeline(340);

  --   ------------------ Serial partition # 1 ------------------

  product_1_mux <= coeff1 WHEN ( cur_count = to_unsigned(0, 9) ) ELSE
                        coeff2 WHEN ( cur_count = to_unsigned(1, 9) ) ELSE
                        coeff3 WHEN ( cur_count = to_unsigned(2, 9) ) ELSE
                        coeff4 WHEN ( cur_count = to_unsigned(3, 9) ) ELSE
                        coeff5 WHEN ( cur_count = to_unsigned(4, 9) ) ELSE
                        coeff6 WHEN ( cur_count = to_unsigned(5, 9) ) ELSE
                        coeff7 WHEN ( cur_count = to_unsigned(6, 9) ) ELSE
                        coeff8 WHEN ( cur_count = to_unsigned(7, 9) ) ELSE
                        coeff9 WHEN ( cur_count = to_unsigned(8, 9) ) ELSE
                        coeff10 WHEN ( cur_count = to_unsigned(9, 9) ) ELSE
                        coeff11 WHEN ( cur_count = to_unsigned(10, 9) ) ELSE
                        coeff12 WHEN ( cur_count = to_unsigned(11, 9) ) ELSE
                        coeff13 WHEN ( cur_count = to_unsigned(12, 9) ) ELSE
                        coeff14 WHEN ( cur_count = to_unsigned(13, 9) ) ELSE
                        coeff15 WHEN ( cur_count = to_unsigned(14, 9) ) ELSE
                        coeff16 WHEN ( cur_count = to_unsigned(15, 9) ) ELSE
                        coeff17 WHEN ( cur_count = to_unsigned(16, 9) ) ELSE
                        coeff18 WHEN ( cur_count = to_unsigned(17, 9) ) ELSE
                        coeff19 WHEN ( cur_count = to_unsigned(18, 9) ) ELSE
                        coeff20 WHEN ( cur_count = to_unsigned(19, 9) ) ELSE
                        coeff21 WHEN ( cur_count = to_unsigned(20, 9) ) ELSE
                        coeff22 WHEN ( cur_count = to_unsigned(21, 9) ) ELSE
                        coeff23 WHEN ( cur_count = to_unsigned(22, 9) ) ELSE
                        coeff24 WHEN ( cur_count = to_unsigned(23, 9) ) ELSE
                        coeff25 WHEN ( cur_count = to_unsigned(24, 9) ) ELSE
                        coeff26 WHEN ( cur_count = to_unsigned(25, 9) ) ELSE
                        coeff27 WHEN ( cur_count = to_unsigned(26, 9) ) ELSE
                        coeff28 WHEN ( cur_count = to_unsigned(27, 9) ) ELSE
                        coeff29 WHEN ( cur_count = to_unsigned(28, 9) ) ELSE
                        coeff30 WHEN ( cur_count = to_unsigned(29, 9) ) ELSE
                        coeff31 WHEN ( cur_count = to_unsigned(30, 9) ) ELSE
                        coeff32 WHEN ( cur_count = to_unsigned(31, 9) ) ELSE
                        coeff33 WHEN ( cur_count = to_unsigned(32, 9) ) ELSE
                        coeff34 WHEN ( cur_count = to_unsigned(33, 9) ) ELSE
                        coeff35 WHEN ( cur_count = to_unsigned(34, 9) ) ELSE
                        coeff36 WHEN ( cur_count = to_unsigned(35, 9) ) ELSE
                        coeff37 WHEN ( cur_count = to_unsigned(36, 9) ) ELSE
                        coeff38 WHEN ( cur_count = to_unsigned(37, 9) ) ELSE
                        coeff39 WHEN ( cur_count = to_unsigned(38, 9) ) ELSE
                        coeff40 WHEN ( cur_count = to_unsigned(39, 9) ) ELSE
                        coeff41 WHEN ( cur_count = to_unsigned(40, 9) ) ELSE
                        coeff42 WHEN ( cur_count = to_unsigned(41, 9) ) ELSE
                        coeff43 WHEN ( cur_count = to_unsigned(42, 9) ) ELSE
                        coeff44 WHEN ( cur_count = to_unsigned(43, 9) ) ELSE
                        coeff45 WHEN ( cur_count = to_unsigned(44, 9) ) ELSE
                        coeff46 WHEN ( cur_count = to_unsigned(45, 9) ) ELSE
                        coeff47 WHEN ( cur_count = to_unsigned(46, 9) ) ELSE
                        coeff48 WHEN ( cur_count = to_unsigned(47, 9) ) ELSE
                        coeff49 WHEN ( cur_count = to_unsigned(48, 9) ) ELSE
                        coeff50 WHEN ( cur_count = to_unsigned(49, 9) ) ELSE
                        coeff51 WHEN ( cur_count = to_unsigned(50, 9) ) ELSE
                        coeff52 WHEN ( cur_count = to_unsigned(51, 9) ) ELSE
                        coeff53 WHEN ( cur_count = to_unsigned(52, 9) ) ELSE
                        coeff54 WHEN ( cur_count = to_unsigned(53, 9) ) ELSE
                        coeff55 WHEN ( cur_count = to_unsigned(54, 9) ) ELSE
                        coeff56 WHEN ( cur_count = to_unsigned(55, 9) ) ELSE
                        coeff57 WHEN ( cur_count = to_unsigned(56, 9) ) ELSE
                        coeff58 WHEN ( cur_count = to_unsigned(57, 9) ) ELSE
                        coeff59 WHEN ( cur_count = to_unsigned(58, 9) ) ELSE
                        coeff60 WHEN ( cur_count = to_unsigned(59, 9) ) ELSE
                        coeff61 WHEN ( cur_count = to_unsigned(60, 9) ) ELSE
                        coeff62 WHEN ( cur_count = to_unsigned(61, 9) ) ELSE
                        coeff63 WHEN ( cur_count = to_unsigned(62, 9) ) ELSE
                        coeff64 WHEN ( cur_count = to_unsigned(63, 9) ) ELSE
                        coeff65 WHEN ( cur_count = to_unsigned(64, 9) ) ELSE
                        coeff66 WHEN ( cur_count = to_unsigned(65, 9) ) ELSE
                        coeff67 WHEN ( cur_count = to_unsigned(66, 9) ) ELSE
                        coeff68 WHEN ( cur_count = to_unsigned(67, 9) ) ELSE
                        coeff69 WHEN ( cur_count = to_unsigned(68, 9) ) ELSE
                        coeff70 WHEN ( cur_count = to_unsigned(69, 9) ) ELSE
                        coeff71 WHEN ( cur_count = to_unsigned(70, 9) ) ELSE
                        coeff72 WHEN ( cur_count = to_unsigned(71, 9) ) ELSE
                        coeff73 WHEN ( cur_count = to_unsigned(72, 9) ) ELSE
                        coeff74 WHEN ( cur_count = to_unsigned(73, 9) ) ELSE
                        coeff75 WHEN ( cur_count = to_unsigned(74, 9) ) ELSE
                        coeff76 WHEN ( cur_count = to_unsigned(75, 9) ) ELSE
                        coeff77 WHEN ( cur_count = to_unsigned(76, 9) ) ELSE
                        coeff78 WHEN ( cur_count = to_unsigned(77, 9) ) ELSE
                        coeff79 WHEN ( cur_count = to_unsigned(78, 9) ) ELSE
                        coeff80 WHEN ( cur_count = to_unsigned(79, 9) ) ELSE
                        coeff81 WHEN ( cur_count = to_unsigned(80, 9) ) ELSE
                        coeff82 WHEN ( cur_count = to_unsigned(81, 9) ) ELSE
                        coeff83 WHEN ( cur_count = to_unsigned(82, 9) ) ELSE
                        coeff84 WHEN ( cur_count = to_unsigned(83, 9) ) ELSE
                        coeff85 WHEN ( cur_count = to_unsigned(84, 9) ) ELSE
                        coeff86 WHEN ( cur_count = to_unsigned(85, 9) ) ELSE
                        coeff87 WHEN ( cur_count = to_unsigned(86, 9) ) ELSE
                        coeff88 WHEN ( cur_count = to_unsigned(87, 9) ) ELSE
                        coeff89 WHEN ( cur_count = to_unsigned(88, 9) ) ELSE
                        coeff90 WHEN ( cur_count = to_unsigned(89, 9) ) ELSE
                        coeff91 WHEN ( cur_count = to_unsigned(90, 9) ) ELSE
                        coeff92 WHEN ( cur_count = to_unsigned(91, 9) ) ELSE
                        coeff93 WHEN ( cur_count = to_unsigned(92, 9) ) ELSE
                        coeff94 WHEN ( cur_count = to_unsigned(93, 9) ) ELSE
                        coeff95 WHEN ( cur_count = to_unsigned(94, 9) ) ELSE
                        coeff96 WHEN ( cur_count = to_unsigned(95, 9) ) ELSE
                        coeff97 WHEN ( cur_count = to_unsigned(96, 9) ) ELSE
                        coeff98 WHEN ( cur_count = to_unsigned(97, 9) ) ELSE
                        coeff99 WHEN ( cur_count = to_unsigned(98, 9) ) ELSE
                        coeff100 WHEN ( cur_count = to_unsigned(99, 9) ) ELSE
                        coeff101 WHEN ( cur_count = to_unsigned(100, 9) ) ELSE
                        coeff102 WHEN ( cur_count = to_unsigned(101, 9) ) ELSE
                        coeff103 WHEN ( cur_count = to_unsigned(102, 9) ) ELSE
                        coeff104 WHEN ( cur_count = to_unsigned(103, 9) ) ELSE
                        coeff105 WHEN ( cur_count = to_unsigned(104, 9) ) ELSE
                        coeff106 WHEN ( cur_count = to_unsigned(105, 9) ) ELSE
                        coeff107 WHEN ( cur_count = to_unsigned(106, 9) ) ELSE
                        coeff108 WHEN ( cur_count = to_unsigned(107, 9) ) ELSE
                        coeff109 WHEN ( cur_count = to_unsigned(108, 9) ) ELSE
                        coeff110 WHEN ( cur_count = to_unsigned(109, 9) ) ELSE
                        coeff111 WHEN ( cur_count = to_unsigned(110, 9) ) ELSE
                        coeff112 WHEN ( cur_count = to_unsigned(111, 9) ) ELSE
                        coeff113 WHEN ( cur_count = to_unsigned(112, 9) ) ELSE
                        coeff114 WHEN ( cur_count = to_unsigned(113, 9) ) ELSE
                        coeff115 WHEN ( cur_count = to_unsigned(114, 9) ) ELSE
                        coeff116 WHEN ( cur_count = to_unsigned(115, 9) ) ELSE
                        coeff117 WHEN ( cur_count = to_unsigned(116, 9) ) ELSE
                        coeff118 WHEN ( cur_count = to_unsigned(117, 9) ) ELSE
                        coeff119 WHEN ( cur_count = to_unsigned(118, 9) ) ELSE
                        coeff120 WHEN ( cur_count = to_unsigned(119, 9) ) ELSE
                        coeff121 WHEN ( cur_count = to_unsigned(120, 9) ) ELSE
                        coeff122 WHEN ( cur_count = to_unsigned(121, 9) ) ELSE
                        coeff123 WHEN ( cur_count = to_unsigned(122, 9) ) ELSE
                        coeff124 WHEN ( cur_count = to_unsigned(123, 9) ) ELSE
                        coeff125 WHEN ( cur_count = to_unsigned(124, 9) ) ELSE
                        coeff126 WHEN ( cur_count = to_unsigned(125, 9) ) ELSE
                        coeff127 WHEN ( cur_count = to_unsigned(126, 9) ) ELSE
                        coeff128 WHEN ( cur_count = to_unsigned(127, 9) ) ELSE
                        coeff129 WHEN ( cur_count = to_unsigned(128, 9) ) ELSE
                        coeff130 WHEN ( cur_count = to_unsigned(129, 9) ) ELSE
                        coeff131 WHEN ( cur_count = to_unsigned(130, 9) ) ELSE
                        coeff132 WHEN ( cur_count = to_unsigned(131, 9) ) ELSE
                        coeff133 WHEN ( cur_count = to_unsigned(132, 9) ) ELSE
                        coeff134 WHEN ( cur_count = to_unsigned(133, 9) ) ELSE
                        coeff135 WHEN ( cur_count = to_unsigned(134, 9) ) ELSE
                        coeff136 WHEN ( cur_count = to_unsigned(135, 9) ) ELSE
                        coeff137 WHEN ( cur_count = to_unsigned(136, 9) ) ELSE
                        coeff138 WHEN ( cur_count = to_unsigned(137, 9) ) ELSE
                        coeff139 WHEN ( cur_count = to_unsigned(138, 9) ) ELSE
                        coeff140 WHEN ( cur_count = to_unsigned(139, 9) ) ELSE
                        coeff141 WHEN ( cur_count = to_unsigned(140, 9) ) ELSE
                        coeff142 WHEN ( cur_count = to_unsigned(141, 9) ) ELSE
                        coeff143 WHEN ( cur_count = to_unsigned(142, 9) ) ELSE
                        coeff144 WHEN ( cur_count = to_unsigned(143, 9) ) ELSE
                        coeff145 WHEN ( cur_count = to_unsigned(144, 9) ) ELSE
                        coeff146 WHEN ( cur_count = to_unsigned(145, 9) ) ELSE
                        coeff147 WHEN ( cur_count = to_unsigned(146, 9) ) ELSE
                        coeff148 WHEN ( cur_count = to_unsigned(147, 9) ) ELSE
                        coeff149 WHEN ( cur_count = to_unsigned(148, 9) ) ELSE
                        coeff150 WHEN ( cur_count = to_unsigned(149, 9) ) ELSE
                        coeff151 WHEN ( cur_count = to_unsigned(150, 9) ) ELSE
                        coeff152 WHEN ( cur_count = to_unsigned(151, 9) ) ELSE
                        coeff153 WHEN ( cur_count = to_unsigned(152, 9) ) ELSE
                        coeff154 WHEN ( cur_count = to_unsigned(153, 9) ) ELSE
                        coeff155 WHEN ( cur_count = to_unsigned(154, 9) ) ELSE
                        coeff156 WHEN ( cur_count = to_unsigned(155, 9) ) ELSE
                        coeff157 WHEN ( cur_count = to_unsigned(156, 9) ) ELSE
                        coeff158 WHEN ( cur_count = to_unsigned(157, 9) ) ELSE
                        coeff159 WHEN ( cur_count = to_unsigned(158, 9) ) ELSE
                        coeff160 WHEN ( cur_count = to_unsigned(159, 9) ) ELSE
                        coeff161 WHEN ( cur_count = to_unsigned(160, 9) ) ELSE
                        coeff162 WHEN ( cur_count = to_unsigned(161, 9) ) ELSE
                        coeff163 WHEN ( cur_count = to_unsigned(162, 9) ) ELSE
                        coeff164 WHEN ( cur_count = to_unsigned(163, 9) ) ELSE
                        coeff165 WHEN ( cur_count = to_unsigned(164, 9) ) ELSE
                        coeff166 WHEN ( cur_count = to_unsigned(165, 9) ) ELSE
                        coeff167 WHEN ( cur_count = to_unsigned(166, 9) ) ELSE
                        coeff168 WHEN ( cur_count = to_unsigned(167, 9) ) ELSE
                        coeff169 WHEN ( cur_count = to_unsigned(168, 9) ) ELSE
                        coeff170 WHEN ( cur_count = to_unsigned(169, 9) ) ELSE
                        coeff171 WHEN ( cur_count = to_unsigned(170, 9) ) ELSE
                        coeff172 WHEN ( cur_count = to_unsigned(171, 9) ) ELSE
                        coeff173 WHEN ( cur_count = to_unsigned(172, 9) ) ELSE
                        coeff174 WHEN ( cur_count = to_unsigned(173, 9) ) ELSE
                        coeff175 WHEN ( cur_count = to_unsigned(174, 9) ) ELSE
                        coeff176 WHEN ( cur_count = to_unsigned(175, 9) ) ELSE
                        coeff177 WHEN ( cur_count = to_unsigned(176, 9) ) ELSE
                        coeff178 WHEN ( cur_count = to_unsigned(177, 9) ) ELSE
                        coeff179 WHEN ( cur_count = to_unsigned(178, 9) ) ELSE
                        coeff180 WHEN ( cur_count = to_unsigned(179, 9) ) ELSE
                        coeff181 WHEN ( cur_count = to_unsigned(180, 9) ) ELSE
                        coeff182 WHEN ( cur_count = to_unsigned(181, 9) ) ELSE
                        coeff183 WHEN ( cur_count = to_unsigned(182, 9) ) ELSE
                        coeff184 WHEN ( cur_count = to_unsigned(183, 9) ) ELSE
                        coeff185 WHEN ( cur_count = to_unsigned(184, 9) ) ELSE
                        coeff186 WHEN ( cur_count = to_unsigned(185, 9) ) ELSE
                        coeff187 WHEN ( cur_count = to_unsigned(186, 9) ) ELSE
                        coeff188 WHEN ( cur_count = to_unsigned(187, 9) ) ELSE
                        coeff189 WHEN ( cur_count = to_unsigned(188, 9) ) ELSE
                        coeff190 WHEN ( cur_count = to_unsigned(189, 9) ) ELSE
                        coeff191 WHEN ( cur_count = to_unsigned(190, 9) ) ELSE
                        coeff192 WHEN ( cur_count = to_unsigned(191, 9) ) ELSE
                        coeff193 WHEN ( cur_count = to_unsigned(192, 9) ) ELSE
                        coeff194 WHEN ( cur_count = to_unsigned(193, 9) ) ELSE
                        coeff195 WHEN ( cur_count = to_unsigned(194, 9) ) ELSE
                        coeff196 WHEN ( cur_count = to_unsigned(195, 9) ) ELSE
                        coeff197 WHEN ( cur_count = to_unsigned(196, 9) ) ELSE
                        coeff198 WHEN ( cur_count = to_unsigned(197, 9) ) ELSE
                        coeff199 WHEN ( cur_count = to_unsigned(198, 9) ) ELSE
                        coeff200 WHEN ( cur_count = to_unsigned(199, 9) ) ELSE
                        coeff201 WHEN ( cur_count = to_unsigned(200, 9) ) ELSE
                        coeff202 WHEN ( cur_count = to_unsigned(201, 9) ) ELSE
                        coeff203 WHEN ( cur_count = to_unsigned(202, 9) ) ELSE
                        coeff204 WHEN ( cur_count = to_unsigned(203, 9) ) ELSE
                        coeff205 WHEN ( cur_count = to_unsigned(204, 9) ) ELSE
                        coeff206 WHEN ( cur_count = to_unsigned(205, 9) ) ELSE
                        coeff207 WHEN ( cur_count = to_unsigned(206, 9) ) ELSE
                        coeff208 WHEN ( cur_count = to_unsigned(207, 9) ) ELSE
                        coeff209 WHEN ( cur_count = to_unsigned(208, 9) ) ELSE
                        coeff210 WHEN ( cur_count = to_unsigned(209, 9) ) ELSE
                        coeff211 WHEN ( cur_count = to_unsigned(210, 9) ) ELSE
                        coeff212 WHEN ( cur_count = to_unsigned(211, 9) ) ELSE
                        coeff213 WHEN ( cur_count = to_unsigned(212, 9) ) ELSE
                        coeff214 WHEN ( cur_count = to_unsigned(213, 9) ) ELSE
                        coeff215 WHEN ( cur_count = to_unsigned(214, 9) ) ELSE
                        coeff216 WHEN ( cur_count = to_unsigned(215, 9) ) ELSE
                        coeff217 WHEN ( cur_count = to_unsigned(216, 9) ) ELSE
                        coeff218 WHEN ( cur_count = to_unsigned(217, 9) ) ELSE
                        coeff219 WHEN ( cur_count = to_unsigned(218, 9) ) ELSE
                        coeff220 WHEN ( cur_count = to_unsigned(219, 9) ) ELSE
                        coeff221 WHEN ( cur_count = to_unsigned(220, 9) ) ELSE
                        coeff222 WHEN ( cur_count = to_unsigned(221, 9) ) ELSE
                        coeff223 WHEN ( cur_count = to_unsigned(222, 9) ) ELSE
                        coeff224 WHEN ( cur_count = to_unsigned(223, 9) ) ELSE
                        coeff225 WHEN ( cur_count = to_unsigned(224, 9) ) ELSE
                        coeff226 WHEN ( cur_count = to_unsigned(225, 9) ) ELSE
                        coeff227 WHEN ( cur_count = to_unsigned(226, 9) ) ELSE
                        coeff228 WHEN ( cur_count = to_unsigned(227, 9) ) ELSE
                        coeff229 WHEN ( cur_count = to_unsigned(228, 9) ) ELSE
                        coeff230 WHEN ( cur_count = to_unsigned(229, 9) ) ELSE
                        coeff231 WHEN ( cur_count = to_unsigned(230, 9) ) ELSE
                        coeff232 WHEN ( cur_count = to_unsigned(231, 9) ) ELSE
                        coeff233 WHEN ( cur_count = to_unsigned(232, 9) ) ELSE
                        coeff234 WHEN ( cur_count = to_unsigned(233, 9) ) ELSE
                        coeff235 WHEN ( cur_count = to_unsigned(234, 9) ) ELSE
                        coeff236 WHEN ( cur_count = to_unsigned(235, 9) ) ELSE
                        coeff237 WHEN ( cur_count = to_unsigned(236, 9) ) ELSE
                        coeff238 WHEN ( cur_count = to_unsigned(237, 9) ) ELSE
                        coeff239 WHEN ( cur_count = to_unsigned(238, 9) ) ELSE
                        coeff240 WHEN ( cur_count = to_unsigned(239, 9) ) ELSE
                        coeff241 WHEN ( cur_count = to_unsigned(240, 9) ) ELSE
                        coeff242 WHEN ( cur_count = to_unsigned(241, 9) ) ELSE
                        coeff243 WHEN ( cur_count = to_unsigned(242, 9) ) ELSE
                        coeff244 WHEN ( cur_count = to_unsigned(243, 9) ) ELSE
                        coeff245 WHEN ( cur_count = to_unsigned(244, 9) ) ELSE
                        coeff246 WHEN ( cur_count = to_unsigned(245, 9) ) ELSE
                        coeff247 WHEN ( cur_count = to_unsigned(246, 9) ) ELSE
                        coeff248 WHEN ( cur_count = to_unsigned(247, 9) ) ELSE
                        coeff249 WHEN ( cur_count = to_unsigned(248, 9) ) ELSE
                        coeff250 WHEN ( cur_count = to_unsigned(249, 9) ) ELSE
                        coeff251 WHEN ( cur_count = to_unsigned(250, 9) ) ELSE
                        coeff252 WHEN ( cur_count = to_unsigned(251, 9) ) ELSE
                        coeff253 WHEN ( cur_count = to_unsigned(252, 9) ) ELSE
                        coeff254 WHEN ( cur_count = to_unsigned(253, 9) ) ELSE
                        coeff255 WHEN ( cur_count = to_unsigned(254, 9) ) ELSE
                        coeff256 WHEN ( cur_count = to_unsigned(255, 9) ) ELSE
                        coeff257 WHEN ( cur_count = to_unsigned(256, 9) ) ELSE
                        coeff258 WHEN ( cur_count = to_unsigned(257, 9) ) ELSE
                        coeff259 WHEN ( cur_count = to_unsigned(258, 9) ) ELSE
                        coeff260 WHEN ( cur_count = to_unsigned(259, 9) ) ELSE
                        coeff261 WHEN ( cur_count = to_unsigned(260, 9) ) ELSE
                        coeff262 WHEN ( cur_count = to_unsigned(261, 9) ) ELSE
                        coeff263 WHEN ( cur_count = to_unsigned(262, 9) ) ELSE
                        coeff264 WHEN ( cur_count = to_unsigned(263, 9) ) ELSE
                        coeff265 WHEN ( cur_count = to_unsigned(264, 9) ) ELSE
                        coeff266 WHEN ( cur_count = to_unsigned(265, 9) ) ELSE
                        coeff267 WHEN ( cur_count = to_unsigned(266, 9) ) ELSE
                        coeff268 WHEN ( cur_count = to_unsigned(267, 9) ) ELSE
                        coeff269 WHEN ( cur_count = to_unsigned(268, 9) ) ELSE
                        coeff270 WHEN ( cur_count = to_unsigned(269, 9) ) ELSE
                        coeff271 WHEN ( cur_count = to_unsigned(270, 9) ) ELSE
                        coeff272 WHEN ( cur_count = to_unsigned(271, 9) ) ELSE
                        coeff273 WHEN ( cur_count = to_unsigned(272, 9) ) ELSE
                        coeff274 WHEN ( cur_count = to_unsigned(273, 9) ) ELSE
                        coeff275 WHEN ( cur_count = to_unsigned(274, 9) ) ELSE
                        coeff276 WHEN ( cur_count = to_unsigned(275, 9) ) ELSE
                        coeff277 WHEN ( cur_count = to_unsigned(276, 9) ) ELSE
                        coeff278 WHEN ( cur_count = to_unsigned(277, 9) ) ELSE
                        coeff279 WHEN ( cur_count = to_unsigned(278, 9) ) ELSE
                        coeff280 WHEN ( cur_count = to_unsigned(279, 9) ) ELSE
                        coeff281 WHEN ( cur_count = to_unsigned(280, 9) ) ELSE
                        coeff282 WHEN ( cur_count = to_unsigned(281, 9) ) ELSE
                        coeff283 WHEN ( cur_count = to_unsigned(282, 9) ) ELSE
                        coeff284 WHEN ( cur_count = to_unsigned(283, 9) ) ELSE
                        coeff285 WHEN ( cur_count = to_unsigned(284, 9) ) ELSE
                        coeff286 WHEN ( cur_count = to_unsigned(285, 9) ) ELSE
                        coeff287 WHEN ( cur_count = to_unsigned(286, 9) ) ELSE
                        coeff288 WHEN ( cur_count = to_unsigned(287, 9) ) ELSE
                        coeff289 WHEN ( cur_count = to_unsigned(288, 9) ) ELSE
                        coeff290 WHEN ( cur_count = to_unsigned(289, 9) ) ELSE
                        coeff291 WHEN ( cur_count = to_unsigned(290, 9) ) ELSE
                        coeff292 WHEN ( cur_count = to_unsigned(291, 9) ) ELSE
                        coeff293 WHEN ( cur_count = to_unsigned(292, 9) ) ELSE
                        coeff294 WHEN ( cur_count = to_unsigned(293, 9) ) ELSE
                        coeff295 WHEN ( cur_count = to_unsigned(294, 9) ) ELSE
                        coeff296 WHEN ( cur_count = to_unsigned(295, 9) ) ELSE
                        coeff297 WHEN ( cur_count = to_unsigned(296, 9) ) ELSE
                        coeff298 WHEN ( cur_count = to_unsigned(297, 9) ) ELSE
                        coeff299 WHEN ( cur_count = to_unsigned(298, 9) ) ELSE
                        coeff300 WHEN ( cur_count = to_unsigned(299, 9) ) ELSE
                        coeff301 WHEN ( cur_count = to_unsigned(300, 9) ) ELSE
                        coeff302 WHEN ( cur_count = to_unsigned(301, 9) ) ELSE
                        coeff303 WHEN ( cur_count = to_unsigned(302, 9) ) ELSE
                        coeff304 WHEN ( cur_count = to_unsigned(303, 9) ) ELSE
                        coeff305 WHEN ( cur_count = to_unsigned(304, 9) ) ELSE
                        coeff306 WHEN ( cur_count = to_unsigned(305, 9) ) ELSE
                        coeff307 WHEN ( cur_count = to_unsigned(306, 9) ) ELSE
                        coeff308 WHEN ( cur_count = to_unsigned(307, 9) ) ELSE
                        coeff309 WHEN ( cur_count = to_unsigned(308, 9) ) ELSE
                        coeff310 WHEN ( cur_count = to_unsigned(309, 9) ) ELSE
                        coeff311 WHEN ( cur_count = to_unsigned(310, 9) ) ELSE
                        coeff312 WHEN ( cur_count = to_unsigned(311, 9) ) ELSE
                        coeff313 WHEN ( cur_count = to_unsigned(312, 9) ) ELSE
                        coeff314 WHEN ( cur_count = to_unsigned(313, 9) ) ELSE
                        coeff315 WHEN ( cur_count = to_unsigned(314, 9) ) ELSE
                        coeff316 WHEN ( cur_count = to_unsigned(315, 9) ) ELSE
                        coeff317 WHEN ( cur_count = to_unsigned(316, 9) ) ELSE
                        coeff318 WHEN ( cur_count = to_unsigned(317, 9) ) ELSE
                        coeff319 WHEN ( cur_count = to_unsigned(318, 9) ) ELSE
                        coeff320 WHEN ( cur_count = to_unsigned(319, 9) ) ELSE
                        coeff321 WHEN ( cur_count = to_unsigned(320, 9) ) ELSE
                        coeff322 WHEN ( cur_count = to_unsigned(321, 9) ) ELSE
                        coeff323 WHEN ( cur_count = to_unsigned(322, 9) ) ELSE
                        coeff324 WHEN ( cur_count = to_unsigned(323, 9) ) ELSE
                        coeff325 WHEN ( cur_count = to_unsigned(324, 9) ) ELSE
                        coeff326 WHEN ( cur_count = to_unsigned(325, 9) ) ELSE
                        coeff327 WHEN ( cur_count = to_unsigned(326, 9) ) ELSE
                        coeff328 WHEN ( cur_count = to_unsigned(327, 9) ) ELSE
                        coeff329 WHEN ( cur_count = to_unsigned(328, 9) ) ELSE
                        coeff330 WHEN ( cur_count = to_unsigned(329, 9) ) ELSE
                        coeff331 WHEN ( cur_count = to_unsigned(330, 9) ) ELSE
                        coeff332 WHEN ( cur_count = to_unsigned(331, 9) ) ELSE
                        coeff333 WHEN ( cur_count = to_unsigned(332, 9) ) ELSE
                        coeff334 WHEN ( cur_count = to_unsigned(333, 9) ) ELSE
                        coeff335 WHEN ( cur_count = to_unsigned(334, 9) ) ELSE
                        coeff336 WHEN ( cur_count = to_unsigned(335, 9) ) ELSE
                        coeff337 WHEN ( cur_count = to_unsigned(336, 9) ) ELSE
                        coeff338 WHEN ( cur_count = to_unsigned(337, 9) ) ELSE
                        coeff339 WHEN ( cur_count = to_unsigned(338, 9) ) ELSE
                        coeff340 WHEN ( cur_count = to_unsigned(339, 9) ) ELSE
                        coeff341;
  mul_temp <= inputmux_1 * product_1_mux;
  product_1 <= mul_temp(46 DOWNTO 0);

  prod_typeconvert_1 <= resize(product_1, 50);

  add_temp <= resize(prod_typeconvert_1, 51) + resize(acc_out_1, 51);
  acc_sum_1 <= add_temp(49 DOWNTO 0);

  acc_in_1 <= prod_typeconvert_1 WHEN ( phase_0 = '1' ) ELSE
                   acc_sum_1;

  Acc_reg_1_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      acc_out_1 <= (OTHERS => '0');
    ELSIF rising_edge(I_CLK) THEN
      acc_out_1 <= acc_in_1;
    END IF; 
  END PROCESS Acc_reg_1_process;

  Finalsum_reg_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      acc_final <= (OTHERS => '0');
    ELSIF rising_edge(I_CLK) THEN
      IF phase_0 = '1' THEN
        acc_final <= acc_out_1;
      END IF;
    END IF; 
  END PROCESS Finalsum_reg_process;

  output_typeconvert <= acc_final;

  Output_Register_process : PROCESS (I_CLK, I_RST)
  BEGIN
    IF I_RST = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF rising_edge(I_CLK) THEN
      IF phase_0 = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  O_FILTER <= std_logic_vector(output_register);
END ARCHITECTURE rtl;
