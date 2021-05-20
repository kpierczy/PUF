library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE0_TEST_RS is                                   	-- deklaracja sprzegu 'DE0_TEST_RS'
  port(
    CLK			:in  std_logic;                         -- odbierany zegar systemowy 50 MHz z plyty DE0
    KEY			:in  std_logic_vector(1 downto 0);      -- odbierany stan przyciskow z plyty DE0
    SW			:in  std_logic_vector(3 downto 0);      -- odbierany stan przelacznikow z plyty DE0
    LED			:out std_logic_vector(7 downto 0);      -- sterowanie diodami LED na plycie DE0
    TXD			:in  std_logic;                         -- odbierane dane szeregowe z plytki CP2102
    RXD			:out std_logic;                         -- wysylane dane szeregowy do plytki CP2102
    RTS			:in  std_logic;                         -- odbierana kontrola szeregowa z plytki CP2102
    CTS			:out std_logic                          -- wysylana kontrola szeregowy do plytki CP2102
  );
end entity DE0_TEST_RS;                                 	-- zakonczenie deklaracji sprzegu

architecture cialo of DE0_TEST_RS is	                	-- deklaracja architektury 'cialo' dla sprzegu 'DE0_TEST_RS'

begin						                -- poczatek czesci wykonawczej architektury

  LED(0) <= CLK;
  RXD <= TXD;
  CTS <= RTS;
  
end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
