library ieee;                                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE_MAX_SIM is                                                    -- deklaracja sprzegu 'DE_MAX_SIM'
  generic(                                                              -- deklaracja parametrow
    WIDTH       :integer := 8                                           -- deklaracja parametru rozmiaru 'WIDTH'
  );                                                                    -- zakonczenie deklaracji parametrow
  port(                                                                 -- deklaracja portow
    R           :in  std_logic;                                         -- deklaracja kasujacego portu wejsciowego 'R'
    S           :in  std_logic;                                         -- deklaracja ustawiajacego portu wejsciowego 'S'
    L           :in  std_logic;                                         -- deklaracja portu wejsciowego zapisu asynchr. 'L'
    V           :in  std_logic_vector(WIDTH-1 downto 0);                -- deklaracja portu wejsc. asynch. wektora danych 'V'
    C           :in  std_logic;                                         -- deklaracja portu wejsciowego zegara 'C'
    E           :in  std_logic;                                         -- deklaracja portu wejsciowego apisu synch. 'E'
    D           :in  std_logic_vector(WIDTH-1 downto 0);                -- deklaracja portu wejsc. synch. wektora danych 'D'
    M           :out std_logic_vector(WIDTH-1 downto 0)                 -- deklaracja portu wyjsciowego wartosci maksimum 'M'
  );                                                                    -- zakonczenie deklaracja portow
end DE_MAX_SIM;                                                         -- zakonczenie deklaracji sprzegu

architecture cialo of DE_MAX_SIM is			                -- deklaracja architektury 'cialo' dla sprzegu 'DE_MAX_SIM'
  signal Q1, Q2, Q3, Q  :std_logic_vector(WIDTH-1 downto 0);            -- deklaracja polaczeniowych wektorow wewnetrznych 
  signal T              :std_logic;                                     -- deklaracja sygnalu wykrycia maksimum
begin                                                                   -- czesc wykonawcza architektury 'cialo'
  reg1: entity work.DE_REG_SIM generic map(WIDTH) port map(R, open, open, open, C, E, D,  Q1); -- instancja rejestru 1 bufora potokowego
  reg2: entity work.DE_REG_SIM generic map(WIDTH) port map(R, open, open, open, C, E, Q1, Q2); -- instancja rejestru 2 bufora potokowego
  reg3: entity work.DE_REG_SIM generic map(WIDTH) port map(R, open, open, open, C, E, Q2, Q3); -- instancja rejestru 3 bufora potokowego
  
  T <= '1' when (Q2>Q1 and Q2>=Q3 and Q2>Q and E='1') else '0';         -- detekcja warunku wartosci maksymalnej: 'T'='1'
  
  regm: entity work.DE_REG_SIM generic map(WIDTH) port map(R, S, L, V, C, T, Q2, Q); -- instancja rejestru wartosci maksymalnej
  M <= Q;
end architecture cialo;                                                 -- zakonczenie architektury 'cialo'
