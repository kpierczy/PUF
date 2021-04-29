library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_ZYBO_Z7 is                                        -- deklaracja sprzegu 'SERIAL_ZYBO_Z7'
  port(
    -- polaczenia do plyty
    SYSCLK              :in  std_logic;                         -- systemowy zegar taktujacy na plycie
    BTN                 :in  std_logic_vector(0 to 3);          -- odczyt stanow pryciskow na plycie
    LED                 :out std_logic_vector(0 to 3);          -- sterowanie diodami del na plycie
    LED_R, LED_G, LED_B :out std_logic;                         -- sterowanie dioda rgb na plycie
    TXD			:in  std_logic;				-- odbierany sygnal szeregowy na plycie
    RXD                 :out std_logic;                         -- wysylany sygnal szeregowy na plycie
    RTS                 :in  std_logic;                         -- odbierany sygnal szeregowy na plycie
    CTS                 :out std_logic;                         -- wysylany sygnal szeregowy na plycie
    -- polaczenia wewnetrzne
    CLK                 :out std_logic;                         -- podstawowy zegar taktujacy
    RES			:out std_logic;                         -- sygnal resetujacacy
    BT1, BT2, BT3       :out std_logic;                         -- odczyt stanów przyciskow
    LD0, LD1, LD2, LD3  :in  std_logic := '0';                  -- sterowanie diodami del
    TX			:out std_logic;				-- odbierany sygnal szeregowy
    RX                  :in  std_logic := '0'                   -- wysylany sygnal szeregowy
  );
end entity SERIAL_ZYBO_Z7;                                      -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_ZYBO_Z7 is	                        -- deklaracja architektury 'cialo' dla sprzegu 'SERIAL_ZYBO_Z7'
  constant  F_ZEGARA    :natural := 20_000_000;		        -- czestotliwosc zegara w [Hz]
  component clk_pll                                             -- deklaracja projektu IP clk_pll
    port(                                                       -- deklaracja portow
      clk_in1           : in     std_logic;                     -- zegar systemowy
      clk_out1          : out    std_logic;                     -- zegar wewnetrzny
      reset             : in     std_logic;                     -- inicjalizacja pll (wysoki)
      locked            : out    std_logic                      -- stan synchronizacji (wysoki)
    );                                                          -- zakonczenie deklaracja portow
  end component;                                                -- zakonczenie deklaracji projektu

  signal   RESET        :std_logic;                             -- sygnal kasujacy
  signal   CLOCK        :std_logic;                             -- zegar podstawowy
  signal   LOCK         :std_logic;                             -- sygnal zalokowania zegara
  signal   licz_led_g   :integer;                               -- licznik dla led green
  signal   licz_led_b   :integer;                               -- licznik dla led blue
  signal   wej_led      :std_logic_vector(0 to 3);              -- wjesciowe stany led
  signal   licz_led     :integer_vector(0 to 3);                -- liczniki dla led

begin						                -- poczatek czesci wykonawczej architektury

  RESET <= BTN(0);                                              -- podlaczenie lokalnego sygnalu RESET
  clk_pll_inst : clk_pll                                        -- instancja projektu IP clk_pll
    port map (                                                  -- mapowanie portow
      clk_in1  => SYSCLK,                                       -- mapowanie  zegara systemowego 125 MHz na plycie
      clk_out1 => CLOCK,                                        -- mapowanie zegara lokalnego 20 MHz dla projektow
      reset    => RESET,                                        -- mapowanie sygnalu inicjalizacji (stan '1')
      locked   => LOCK                                          -- mapowanie sygnalizacji zaalokowania zegarow (stan '1')
    );

  process(RESET, CLOCK) is begin		                -- proces permanentnego odliczania okresu 1s
    if (RESET='1') then						-- asynchroniczna inicjalizacja licznika sygnalem RESET
      licz_led_g <= 0;                                          -- asynch. ustawienie licznika 'licz_led_g' na wartosc 0
    elsif (CLOCK'event and CLOCK='1') then			-- synchroniczna cykl odliczania narastajacym zboczem CLOCK
      licz_led_g <= (licz_led_g + 1) mod F_ZEGARA;		-- synch. zwiekszenie 'licz_led_g' o 1 w zakresie do F_ZEGARA-1
    end if;						        -- zakonczenie instukcji warunkowej
  end process;					                -- zakonczenie procesu odliczania okresu 1s

  process(RESET, CLOCK) is begin                                -- proces odliczania okresu 1/10s dla diody RGB
    if (RESET='1') then						-- asynchroniczna inicjalizacja licznika sygnalem RESET
      licz_led_b <= 0;                                          -- asynch. ustawienie licznika 'licz_led_b' na wartosc 0
    elsif (CLOCK'event and CLOCK='1') then			-- synchroniczny cykl odliczania narastajacym zboczem CLOCK
      if (OR_REDUCE(BTN)='1' or TXD='0' or RX='0') then         -- badanie stanu '1' na dowolnym bicie 'BTN', TXD' lub 'RXD'
        licz_led_b <= 1;                                        -- synch. przypisanie licznikowi 'licz_led_b' wartosci 1
      elsif (licz_led_b=0) then                                 -- badanie czy licznik 'licz_led_b' ma wartosci 0
        null;                                                   -- pusta intrukcja
      elsif (licz_led_b<(F_ZEGARA/10)) then                     -- badanie czy licznik 'licz_led_b' nie osiagnal F_ZEGARA/10
        licz_led_b <= licz_led_b + 1;                           -- synch. zwiekszenie liczniaka ''licz_led_b' o warosc 1
      elsif (licz_led_b=(F_ZEGARA/10)) then                     -- badanie czy licznik 'licz_led_b' osiagnal F_ZEGARA/10
        licz_led_b <= 0;                                        -- synch. przypisanie licznikowi 'licz_led_b' wartosci 0
      end if;                                                   -- zakonczenie wielokrotnych warunkow stanu licznika
    end if;                                                     -- zakonczenie wielokrotnych warunkow procesu
  end process;                                                  -- zakonczenie procesu

  LED_R <= not(LOCK) or RESET;                                  -- asynch. przypisanie wyrazenia do portu 'LED_R'
  LED_G <= '1' when (licz_led_g<F_ZEGARA/10 and licz_led_b<=1) else '0'; -- asynch. przypisanie wyrazenia do portu 'LED_G'
  LED_B <= '1' when (licz_led_b>0) else '0';                    -- asynch. przypisanie wyrazenia do portu 'LED_B'

  wej_led(0) <= LD0;                                            -- asynch. przypisanie do sygnalu 'wej_led(0)' z portu 'LD0'
  wej_led(1) <= LD1;                                            -- asynch. przypisanie do sygnalu 'wej_led(1)' z portu 'LD1'
  wej_led(2) <= LD2;                                            -- asynch. przypisanie do sygnalu 'wej_led(2)' z portu 'LD2'
  wej_led(3) <= LD3;                                            -- asynch. przypisanie do sygnalu 'wej_led(3)' z portu 'LD3'

  process(RESET, CLOCK) is begin                                -- proces odliczania okresu 1/10s dla diod LD0-4
    if (RESET='1') then						-- asynchroniczna inicjalizacja licznika sygnalem RESET
      licz_led <= (others => 0);                                -- asynch. ustawienie licznika 'licz_led' na wartosc 0
    elsif (CLOCK'event and CLOCK='1') then                      -- synchroniczny cykl odliczania narastajacym zboczem CLOCK
      for i in wej_led'range loop				-- petla sekwencyjna po kolejnych bitach wektora 'wej_led'
        if (wej_led(i)='1') then                                -- badanie stanu '1' na bicie 'wej_led(i)'
          licz_led(i) <= 1;                                     -- synch. przypisanie licznikowi 'licz_led' wartosci 1
        elsif (licz_led(i)=0) then                              -- badanie czy licznik 'licz_led' ma wartosci 0
          null;                                                 -- pusta intrukcja
        elsif (licz_led(i)<(F_ZEGARA/10)) then                  -- badanie czy licznik 'licz_led' nie osiagnal F_ZEGARA/10
          licz_led(i) <= licz_led(i) + 1;                       -- synch. zwiekszenie liczniaka ''licz_led' o warosc 1
        elsif (licz_led(i)=(F_ZEGARA/10)) then                  -- badanie czy licznik 'licz_led' osiagnal F_ZEGARA/10
          licz_led(i) <= 0;                                     -- synch. przypisanie licznikowi 'licz_led' wartosci 0
        end if;                                                 -- zakonczenie wielokrotnych warunkow stanu licznika
      end loop;							-- zakonczenie cyklu petli sekwencyjnej
    end if;                                                     -- zakonczenie wielokrotnych warunkow procesu
  end process;                                                  -- zakonczenie procesu

  ll: for i in wej_led'range generate				-- petla generacji po kolejnych bitach wektora 'wej_led'
    LED(i) <= '1' when (wej_led(i)='1' or licz_led(i)>0) else '0';  -- warunkowe przypisanie do portu 'LED(i)'
  end generate;							-- zakonczenie cyklu petli generacji

  CTS <= RTS;							-- zapetlenie sygnalu sterowania odbioru i nadawania szeregowego

  BT1 <= BTN(1); BT2 <= BTN(2); BT3 <= BTN(3);                  -- asynch. polaczenie portow przelacznikow
  RES <= RESET;							-- asynch. polaczenie portow resetu
  CLK <= CLOCK;							-- asynch. przypisanie portu do zegara lokalnego 'CLOCK'
  TX  <= TXD;							-- asynch. polaczenie portow nadawania szeregowego
  RXD <= RX;							-- asynch. polaczenie portow odbioru szeregowego

end architecture cialo;                                 	-- zakonczenie architektury 'cialo'

----------------------------------------------------------------------------------------------

library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_ZYBO_Z7_TEST is                                   -- deklaracja sprzegu 'SERIAL_ZYBO_Z7_TEST'
  port(
    SYSCLK              :in  std_logic;                         -- systemowy zegar taktujacy na plycie
    BTN                 :in  std_logic_vector(0 to 3);          -- odczyt stanow pryciskow na plycie
    LED                 :out std_logic_vector(0 to 3);          -- sterowanie diodami del na plycie
    LED_R, LED_G, LED_B :out std_logic;                         -- sterowanie dioda rgb na plycie
    TXD			:in  std_logic;				-- odbierany sygnal szeregowy na plycie
    RXD                 :out std_logic;                         -- wysylany sygnal szeregowy na plycie
    RTS                 :in  std_logic;                         -- odbierany sygnal szeregowy na plycie
    CTS                 :out std_logic                          -- wysylany sygnal szeregowy na plycie
  );
end entity SERIAL_ZYBO_Z7_TEST;                                 -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_ZYBO_Z7_TEST is	                -- deklaracja architektury 'cialo' dla sprzegu 'SERIAL_ZYBO_Z7_TEST'

 signal RES             :std_logic;                             -- sygnal resetujacacy
 signal CLK             :std_logic;                             -- systemowy zegar taktujacy
 signal TX              :std_logic;                             -- odbierany sygnal szeregowy
 signal BT1, BT2, BT3   :std_logic;                             -- stan zatrzymania

begin						                -- poczatek czesci wykonawczej architektury

  zybo_inst: entity work.SERIAL_ZYBO_Z7				-- instancja projetu 'SERIAL_ZYBO_Z7'
    port map(							-- mapowanie portow
      SYSCLK            => SYSCLK,
      BTN               => BTN,
      LED               => LED,
      LED_R             => LED_R,
      LED_G             => LED_G,
      LED_B             => LED_B,
      TXD               => TXD,
      RXD               => RXD,
      RTS               => RTS,
      CTS               => CTS,
      CLK               => open,
      RES               => RES,
      BT1               => BT1,
      BT2               => BT2,
      BT3               => BT3,
      LD0               => RES,
      LD1               => BT1,
      LD2               => BT2,
      LD3               => BT3,
      TX                => TX,
      RX                => TX
    );

end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
