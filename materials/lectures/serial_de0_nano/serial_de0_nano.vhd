library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity SERIAL_DE0_NANO is                                       -- deklaracja sprzegu 'SERIAL_DE0_NANO'
  port (                                                        -- deklaracja portow wejscia-wyjscia
    -- polaczenia do plyty
    DE0_CLK             :in  std_logic;                         -- odbierany zegar systemowy 50 MHz z plyty DE0
    DE0_KEY             :in  std_logic_vector(1 downto 0);      -- odbierany stan przyciskow z plyty DE0
    DE0_SW              :in  std_logic_vector(3 downto 0);      -- odbierany stan przelacznikow z plyty DE0
    DE0_LED             :out std_logic_vector(7 downto 0);      -- sterowanie diodami LED na plytcie DE0
    DE0_TXD             :in  std_logic;                         -- odbierane dane szeregowe z plyty DE0
    DE0_RXD             :out std_logic;                         -- wysylane dane szeregowy do plyty DE0
    DE0_RTS             :in  std_logic;                         -- odbierana kontrola szeregowa z plyty DE0
    DE0_CTS             :out std_logic;                         -- wysylana kontrola szeregowy do plyty DE0
    -- polaczenia wewnetrzne
    CLK                 :out std_logic;                         -- podstawowy zegar taktujacy 20 MHz
    RES                 :out std_logic;                         -- sygnal resetujacacy
    BUT                 :out std_logic;                         -- stan przycisku
    SW                  :out std_logic_vector(3 downto 0);      -- stan przelacznikow
    LED                 :in  std_logic_vector(3 downto 0);      -- sterowanie diodami 'LED'
    TXD                 :out std_logic;                         -- odbierane dane szeregowe
    RXD                 :in  std_logic := '0'                   -- wysylane dane szeregowe
  );
end SERIAL_DE0_NANO;                                            -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_DE0_NANO is                        -- deklaracja ciala 'cialo' architektury

  constant  F_ZEGARA    :natural := 20_000_000;                 -- czestotliwosc zegara podstawowego w [Hz]

  signal   RESET        :std_logic;                             -- sygnal kasujacy
  signal   CLOCK        :std_logic;                             -- zegar podstawowy
  signal   LOCK         :std_logic;                             -- sygnal zalokowania zegara
  signal   licz_clk     :integer;                               -- licznik dla diody zegara
  signal   licz_rs      :integer;                               -- licznik dla diody transmisji
  signal   licz_led     :integer_vector(LED'range);             -- liczniki dla diod LED

  component clk_pll                                             -- deklaracja projektu IP clk_pll
    port(                                                       -- deklaracja portow
      refclk   : in  std_logic := '0';                          -- wejsciowy zegar systemowy
      rst      : in  std_logic := '0';                          -- inicjalizacja pll (wysoki)
      outclk_0 : out std_logic;                                 -- wyjsciowy zegar podstawowy
      locked   : out std_logic                                  -- stan synchronizacji (wysoki)
    );
  end component;

begin                                                           -- poczatek czesci wykonawczej architektury

  RESET <= not(DE0_KEY(0));                                     -- podlaczenie lokalnego sygnalu RESET
  clk_pll_inst : clk_pll                                        -- instancja projektu IP clk_pll
    port map (                                                  -- mapowanie portow
      refclk   => DE0_CLK,                                      -- mapowanie  zegara systemowego 50 MHz na plycie
      outclk_0 => CLOCK,                                        -- mapowanie zegara lokalnego 20 MHz dla projektow
      rst      => RESET,                                        -- mapowanie sygnalu inicjalizacji (stan '1')
      locked   => LOCK                                          -- mapowanie sygnalizacji zaalokowania zegarow (stan '1')
    );

  process(RESET, CLOCK) is begin                                -- proces permanentnego odliczania okresu 1s
    if (RESET='1') then                                         -- asynchroniczna inicjalizacja licznika sygnalem RESET
      licz_clk <= 0;                                            -- asynch. ustawienie licznika 'licz_clk' na wartosc 0
    elsif (CLOCK'event and CLOCK='1') then                      -- synchroniczna cykl odliczania narastajacym zboczem CLOCK
      licz_clk <= (licz_clk + 1) mod F_ZEGARA;                  -- synch. zwiekszenie 'licz_clk' o 1 w zakresie do F_ZEGARA-1
    end if;                                                     -- zakonczenie instukcji warunkowej
  end process;                                                  -- zakonczenie procesu odliczania okresu 1s

  process(RESET, CLOCK) is begin                                -- proces odliczania okresu 1/10s dla danych transmisji RS
    if (RESET='1') then                                         -- asynchroniczna inicjalizacja licznika sygnalem RESET
      licz_rs <= 0;                                             -- asynch. ustawienie licznika 'licz_rs' na wartosc 0
    elsif (CLOCK'event and CLOCK='1') then                      -- synchroniczny cykl odliczania narastajacym zboczem CLOCK
      if (DE0_TXD='0' or RXD='0') then                          -- badanie stanu '1' na dowolnym bicie 'DE0_TXD' lub 'RXD'
        licz_rs <= 1;                                           -- synch. przypisanie licznikowi 'licz_rs' wartosci 1
      elsif (licz_rs=0) then                                    -- badanie czy licznik 'licz_rs' ma wartosci 0
        null;                                                   -- pusta intrukcja
      elsif (licz_rs<(F_ZEGARA/10)) then                        -- badanie czy licznik 'licz_rs' nie osiagnal F_ZEGARA/10
        licz_rs <= licz_rs + 1;                                 -- synch. zwiekszenie liczniaka 'licz_rs' o warosc 1
      elsif (licz_rs=(F_ZEGARA/10)) then                        -- badanie czy licznik 'licz_rs' osiagnal F_ZEGARA/10
        licz_rs <= 0;                                           -- synch. przypisanie licznikowi 'licz_rs' wartosci 0
      end if;                                                   -- zakonczenie wielokrotnych warunkow stanu licznika
    end if;                                                     -- zakonczenie wielokrotnych warunkow procesu
  end process;                                                  -- zakonczenie procesu

  DE0_LED(7) <= '1' when (RESET='1' OR LOCK='0') else '0';      -- asynch. przypisanie warunku zapalenia diody 'DE0_LED(7)'
  DE0_LED(6) <= '1' when (licz_clk<F_ZEGARA/10)  else '0';      -- asynch. przypisanie warunku zapalenia diody 'DE0_LED(6)'
  DE0_LED(5) <= '1' when (licz_rs>0)             else '0';      -- asynch. przypisanie warunku zapalenia diody 'DE0_LED(5)'
  DE0_LED(4) <= '1' when (DE0_KEY(1)='0')        else '0';      -- asynch. przypisanie warunku zapalenia diody 'DE0_LED(4)'

  process(RESET, CLOCK) is begin                                -- proces odliczania okresu 1/10s dla diod LD0-3
    if (RESET='1') then                                         -- asynchroniczna inicjalizacja licznika sygnalem RESET
      licz_led <= (others => 0);                                -- asynch. ustawienie licznika 'licz_led' na wartosc 0
    elsif (CLOCK'event and CLOCK='1') then                      -- synchroniczny cykl odliczania narastajacym zboczem CLOCK
      for i in LED'range loop                                   -- petla sekwencyjna po kolejnych bitach wektora 'LED'
        if (LED(i)='1') then                                    -- badanie stanu '1' na bicie 'LED(i)'
          licz_led(i) <= 1;                                     -- synch. przypisanie licznikowi 'licz_led' wartosci 1
        elsif (licz_led(i)=0) then                              -- badanie czy licznik 'licz_led' ma wartosci 0
          null;                                                 -- pusta intrukcja
        elsif (licz_led(i)<(F_ZEGARA/10)) then                  -- badanie czy licznik 'licz_led' nie osiagnal F_ZEGARA/10
          licz_led(i) <= licz_led(i) + 1;                       -- synch. zwiekszenie liczniaka ''licz_led' o warosc 1
        elsif (licz_led(i)=(F_ZEGARA/10)) then                  -- badanie czy licznik 'licz_led' osiagnal F_ZEGARA/10
          licz_led(i) <= 0;                                     -- synch. przypisanie licznikowi 'licz_led' wartosci 0
        end if;                                                 -- zakonczenie wielokrotnych warunkow stanu licznika
      end loop;                                                 -- zakonczenie cyklu petli sekwencyjnej
    end if;                                                     -- zakonczenie wielokrotnych warunkow procesu
  end process;                                                  -- zakonczenie procesu

  ll: for i in LED'range generate                               -- petla generacji po kolejnych bitach wektora 'LED'
    DE0_LED(i) <= '1' when (LED(i)='1' or licz_led(i)>0) else '0';  -- warunkowe przypisanie do portu 'LED(i)'
  end generate;                                                 -- zakonczenie cyklu petli generacji


  BUT     <= not(DE0_KEY(1));                                   -- asynch. polaczenie portu przycisku
  SW      <= DE0_SW;                                            -- asynch. polaczenie portow przelacznikow
  RES     <= RESET;                                             -- asynch. polaczenie portow resetu
  CLK     <= CLOCK;                                             -- asynch. przypisanie portu do zegara lokalnego 'CLOCK'
  TXD     <= DE0_TXD;                                           -- asynch. polaczenie portow nadawania szeregowego z komputera
  DE0_RXD <= RXD;                                               -- asynch. polaczenie portow odbioru szeregowego przez komputer
  DE0_CTS <= DE0_RTS;                                           -- zapetlenie sygnalu sterowania odbioru i nadawania szeregowego

end architecture cialo;                                         -- zakonczenie architektury 'cialo'

----------------------------------------------------------------------------------------------

library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity SERIAL_DE0_NANO_TOP is                                  	-- deklaracja sprzegu 'SERIAL_DE0_NANO'
  port(
    DE0_CLK             :in  std_logic;                         -- odbierany zegar systemowy 50 MHz z plyty DE0
    DE0_KEY             :in  std_logic_vector(1 downto 0);      -- odbierany stan przyciskow z plyty DE0
    DE0_SW              :in  std_logic_vector(3 downto 0);      -- odbierany stan przelacznikow z plyty DE0
    DE0_LED             :out std_logic_vector(7 downto 0);      -- sterowanie diodami LED na plytcie DE0
    DE0_TXD             :in  std_logic;                         -- odbierane dane szeregowe z plyty DE0
    DE0_RXD             :out std_logic;                         -- wysylane dane szeregowy do plyty DE0
    DE0_RTS             :in  std_logic;                         -- odbierana kontrola szeregowa z plyty DE0
    DE0_CTS             :out std_logic                          -- wysylana kontrola szeregowy do plyty DE0
  );
end entity SERIAL_DE0_NANO_TOP;                                 -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_DE0_NANO_TOP is	                -- deklaracja architektury 'cialo' dla sprzegu 'SERIAL_DE0_NANO_TOP'

 signal RS              :std_logic;                             -- transmitowany sygnal szeregowy
 signal SW              :std_logic_vector(3 downto 0);          -- stan przlacznikow

begin						                -- poczatek czesci wykonawczej architektury

  DE0_inst: entity work.SERIAL_DE0_NANO				-- instancja projektu 'SERIAL_DE0_NANO'
    port map(							-- mapowanie portow
      DE0_CLK     	=> DE0_CLK,
      DE0_KEY     	=> DE0_KEY,
      DE0_SW      	=> DE0_SW,
      DE0_LED     	=> DE0_LED,
      DE0_TXD     	=> DE0_TXD,
      DE0_RXD     	=> DE0_RXD,
      DE0_RTS     	=> DE0_RTS,
      DE0_CTS     	=> DE0_CTS,
      CLK               => open,
      RES               => open,
      BUT               => open,
      SW                => SW,
      LED               => SW,
      TXD               => RS,
      RXD               => RS
    );

end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
