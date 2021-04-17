library ieee;                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity SR_SYNC is                               -- deklaracja sprzegu 'SR_SYNC'
  port(                                         -- deklaracja portow
    R                   :in  std_logic;         -- deklaracja kasujacego portu wejsciowego 'R'
    S			:in  std_logic;         -- deklaracja ustawiajacego portu wejsciowego 'S'
    Q			:out std_logic          -- deklaracja portu wyjsciowego stanu 'Q'
  );
end SR_SYNC;                                    -- zakonczenie deklaracji sprzegu

architecture cialo of SR_SYNC is		-- deklaracja architektury 'cialo' dla sprzegu 'SR_SYNC'
  signal   Qres		:std_logic;             -- deklaracja sygnalu kasowania asynchonicznego 'Qres'
  signal   Qset		:std_logic;             -- deklaracja sygnalu ustawiania synchronicznego 'Qset'
  signal   Qreg		:std_logic := '0';      -- deklaracja sygnalu stanu przerzutnika 'Qreg'
begin
  Qres <= R and Qreg;                           -- asynchroniczne przypisanie wyrazenia do sygnalu 'Qres' 
  Qset <= S and not(R);                         -- asynchroniczne przypisanie wyrazenia do sygnalu 'Qset'

  process (Qres, Qset) is begin                 -- lista czulosci procesu
    if (Qres='1') then                          -- badanie, czy sygnal 'Qres' ma wartosc '1'
      Qreg <='0';                               -- jeœli tak, asynchroniczne ustawienie 'Qreg' na wartosc '0'
    elsif(Qset'event and Qset='1') then         -- alternatywne badanie, czy wystapilo zbocze narastajace na sygnale 'Qset'
      Qreg <='1';                               -- jeœli tak, synchroniczne ustawienie 'Qreg' na wartosc '1'
    end if;                                     -- zakonczenie warunku
  end process;                                  -- zakonczenie procesu

  Q <= Qreg;                                    -- asynchroniczne sygnalu 'Qreg' do portu wyjsciowego 'Q'
end architecture cialo;                         -- zakonczenie architektury 'cialo'			   

---------------------------------------------------------------------------------

library ieee;                                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE_REG_SYNC is                                                           -- deklaracja sprzegu 'DE_REG_SYNC'
  generic(                                                                      -- deklaracja parametrow
    WIDTH       :integer := 1                                                   -- deklaracja parametru rozmiaru 'WIDTH'
  );                                                                            -- zakonczenie deklaracji parametrow
  port(                                                                         -- deklaracja portow
    R           :in  std_logic := '0';                                          -- deklaracja kasujacego portu wejsciowego 'R'
    S           :in  std_logic := '0';                                          -- deklaracja ustawiajacego portu wejsciowego 'S'
    L           :in  std_logic := '0';                                          -- deklaracja portu wejsciowego zapisu asynchr. 'L'
    V           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');     -- deklaracja portu wejsc. asynch. wektora danych 'V'
    C           :in  std_logic := '0';                                          -- deklaracja portu wejsciowego zegara 'C'
    E           :in  std_logic := '1';                                          -- deklaracja portu wejsciowego apisu synch. 'E'
    D           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');     -- deklaracja portu wejsc. synch. wektora danych 'D'
    Q           :out std_logic_vector(WIDTH-1 downto 0)                         -- deklaracja portu wyjsciowego danych 'Q'
  );                                                                            -- zakonczenie deklaracja portow
end DE_REG_SYNC;                                                                -- zakonczenie deklaracji sprzegu

architecture cialo of DE_REG_SYNC is			                        -- deklaracja architektury 'cialo' dla sprzegu 'DE_REG_SYNC'
  signal   Rvec		:std_logic_vector(WIDTH-1 downto 0);                    -- deklaracja wektora wejscia kasowania 'R'
  signal   Svec		:std_logic_vector(WIDTH-1 downto 0);                    -- deklaracja wektora wejscia ustawiania S'
  signal   Lvec		:std_logic_vector(WIDTH-1 downto 0);                    -- deklaracja wektora wejscia zapisu asynchronicznego 'L'
  signal   Qres		:std_logic_vector(WIDTH-1 downto 0);                    -- deklaracja wektora kasowania dla projektu 'RS_SYNC'
  signal   Qset		:std_logic_vector(WIDTH-1 downto 0);                    -- deklaracja wektora ustawiania dla projektu 'RS_SYNC'
  signal   Qrs		:std_logic_vector(WIDTH-1 downto 0);                    -- deklaracja wektora stanu z projektu 'RS_SYNC'
  signal   Qreg1,Qreg2	:std_logic_vector(WIDTH-1 downto 0) := (others => '0'); -- deklaracja wektorow rejestrow dla obu zboczy zegara 'C'
begin						                                -- poczatek czesci wykonawczej architektury
  Rvec <= (others => R);						        -- asynchroniczne przypisanie wektora 'Rvec'
  Svec <= (others => S);						        -- asynchroniczne przypisanie wektora 'Svec'
  Lvec <= (others => L);						        -- asynchroniczne przypisanie wektora 'Lvec'
  Qres <= Rvec or (not(Svec) and Lvec and not(V));				-- asynchroniczne przypisanie wektora 'Qres'
  Qset <= Svec or (not(Rvec) and Lvec and     V );				-- asynchroniczne przypisanie wektora 'Qset'

  lp: for i in 0 to WIDTH-1 generate                                            -- petla 'WIDTH' generacji 
    rs: entity work.SR_SYNC port map (Qres(i), Qset(i), Qrs(i));                -- wielokrotna instancja projektu 'RS_SYNC'
  end generate;                                                                 -- zakonczenie petli generacji

  process (R, S, L, C) is begin                                                 -- lista czulosci procesu
    if (R='1' or S='1' or L='1') then                                           -- badanie, czy sygnal 'R' lub 'S' lub 'L' ma wartosc '1'
      Qreg1 <= (others => '0');                                                 -- jeœli tak, asynch. ustaw. wektora 'Qreg1' na wartosci '0'
    elsif(C'event and C='1') then                                               -- alternatywne badanie, czy wystapilo zbocze narastajace na 'C'
      if (E='1') then                                                           -- badanie, czy sygnal 'E' ma wartosc '1'
        Qreg1 <= D xor Qrs xor Qreg2;                                           -- jeœli oba tak, synch. przypisanie wyrazenia do 'Qreg1'
      end if;                                                                   -- zakonczenie warunku zapisu synchronicznego
    end if;                                                                     -- zakonczenie wielokrotnych warunkow 
  end process;                                                                  -- zakonczenie procesu

  process (R, S, L, C) is begin                                                 -- lista czulosci procesu
    if (R='1' or S='1' or L='1') then                                           -- badanie, czy sygnal 'R' lub 'S' lub 'L' ma wartosc '1'
      Qreg2 <= (others => '0');                                                 -- jeœli tak, asynch. ustaw. wektora 'Qreg2' na wartosci '0'
    elsif(C'event and C='0') then                                               -- alternatywne badanie, czy wystapilo zbocze opadajace na 'C'
      if (E='1') then                                                           -- badanie, czy sygnal 'E' ma wartosc '1'
        Qreg2 <= D xor Qrs xor Qreg1;                                           -- jeœli oba tak, synch. przypisanie wyrazenia do 'Qreg2'
      end if;                                                                   -- zakonczenie warunku zapisu synchronicznego
    end if;                                                                     -- zakonczenie wielokrotnych warunkow 
  end process;                                                                  -- zakonczenie procesu

  Q <= Qreg1 xor Qreg2 xor Qrs;                                                 -- asynchroniczne przypisanie wyrazenia do portu wyjsciowego 'Q'
end architecture cialo;                                                         -- zakonczenie architektury 'cialo'

