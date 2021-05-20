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

---------------------------------------------------------------------------------

library ieee;                                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE_REG_ASYNC is                                                          -- deklaracja sprzegu 'DE_REG_ASYNC'
  generic(                                                                      -- deklaracja parametrow
    WIDTH       :integer := 1                                                   -- deklaracja parametru rozmiaru 'WIDTH'
  );                                                                            -- zakonczenie deklaracji parametrow
  port(                                                                         -- deklaracja portow
    R           :in  std_logic := '0';                                          -- deklaracja kasujacego portu wejsciowego 'R'
    S           :in  std_logic := '0';                                          -- deklaracja ustawiajacego portu wejsciowego 'S'
    L           :in  std_logic := '0';                                          -- deklaracja portu wejsciowego zapisu asynchr. 'L'
    V           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');     -- deklaracja portu wejsc. asynch. wektora danych 'V'
    C           :in  std_logic := '0';                                          -- deklaracja portu wejsciowego zegara 'C'
    E           :in  std_logic := '1';                                          -- deklaracja portu wejsciowego zapisu synch. 'E'
    D           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');     -- deklaracja portu wejsc. synch. wektora danych 'D'
    Q           :out std_logic_vector(WIDTH-1 downto 0)                         -- deklaracja portu wyjsciowego danych 'Q'
  );                                                                            -- zakonczenie deklaracja portow
end DE_REG_ASYNC;                                                               -- zakonczenie deklaracji sprzegu
  
architecture cialo of DE_REG_ASYNC is                                           -- deklaracja architektury 'cialo' dla sprzegu 'DE_REG_ASYNC'
  signal   Qreg1,Qreg2	:std_logic_vector(WIDTH-1 downto 0) := (others => '0'); -- deklaracje wektorow rejestrow dla obu zboczy zegara 'C'
begin						                                -- poczatek czesci wykonawczej architektury
  process (R, S, L, V, C) is begin                                              -- lista czulosci procesu
    if (R='1') then                                                             -- badanie, czy sygnal 'R' ma wartosc '1'
      Qreg1 <= (others => '0');                                                 -- jeœli tak, asynch. ustaw. bitow 'Qreg1' na wartosc '0'
    elsif (S='1') then                                                          -- badanie, czy sygnal 'S' ma wartosc '1'
      Qreg1 <= (others => '1');                                                 -- jeœli tak, asynch. ustaw. bitow 'Qreg1' na wartosc '1'
    elsif (L='1') then                                                          -- badanie, czy sygnal 'L' ma wartosc '1'
      Qreg1 <= V;                                                               -- jeœli tak, asynch. przypisanie do 'Qreg1' wektora 'V'
    elsif (C'event and C='1') then                                              -- alternatywne badanie, czy wystapilo zbocze narastajace na 'C'
      if (E='1') then                                                           -- badanie, czy sygnal 'E' ma wartosc '1'
        Qreg1 <= D xor Qreg2;                                                   -- jeœli oba tak, synch. przypisanie wyrazenia do 'Qreg1'
      end if;                                                                   -- zakonczenie warunku zapisu synchronicznego
    end if;                                                                     -- zakonczenie wielokrotnych warunkow 
  end process;                                                                  -- zakonczenie procesu

  process (R, S, L, V, C) is begin
    if (R='1' or S='1' or L='1') then                                           -- badanie, czy sygnal 'R' lub 'S' lub 'L' ma wartosc '1'
      Qreg2 <= (others => '0');                                                 -- jeœli tak, asynch. ustaw. wektora 'Qreg2' na wartosci '0'
    elsif (C'event and C='0') then                                              -- alternatywne badanie, czy wystapilo zbocze opadajace 'C'
      if (E='1') then                                                           -- badanie, czy sygnal 'E' ma wartosc '1'
        Qreg2 <= D xor Qreg1;                                                   -- jeœli oba tak, synch. przypisanie wyrazenia do 'Qreg2'
      end if;                                                                   -- zakonczenie warunku zapisu synchronicznego
    end if;                                                                     -- zakonczenie wielokrotnych warunkow 
  end process;                                                                  -- zakonczenie procesu

  Q <= Qreg1 xor Qreg2;                                                         -- asynchroniczne przypisanie wyrazenia do portu wyjsciowego 'Q'
end architecture cialo;                                                         -- zakonczenie architektury 'cialo'
			   
---------------------------------------------------------------------------------

library ieee;                                                -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                             -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE_REG_IMPL is                                        -- deklaracja sprzegu 'DE_REG_IMPL'
  generic(                                                   -- deklaracja parametrow
    WIDTH       :integer := 1                                -- deklaracja parametru rozmiaru 'WIDTH'
  );                                                         -- zakonczenie deklaracji parametrow
  port(                                                      -- deklaracja portow
    sR           :in  std_logic := '0';                      -- deklaracja kasujacego portu wejsciowego 'sR' dla projetu 'DE_REG_SYNC'
    sS           :in  std_logic := '0';                      -- deklaracja ustawiajacego portu wejsciowego 'sS' dla projetu 'DE_REG_SYNC'
    sL           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zapisu asynchr. 'sL' dla projetu 'DE_REG_SYNC'
    sV           :in  std_logic_vector(WIDTH-1 downto 0);    -- deklaracja portu wejsc. asynch. wektora danych 'sV' dla projetu 'DE_REG_SYNC'
    sC           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zegara 'sC' dla projetu 'DE_REG_SYNC'
    sE           :in  std_logic := '1';                      -- deklaracja portu wejsciowego zapisu synch. 'sE' dla projetu 'DE_REG_SYNC'
    sD           :in  std_logic_vector(WIDTH-1 downto 0);    -- deklaracja portu wejsc. synch. wektora danych 'sD' dla projetu 'DE_REG_SYNC'
    sQ           :out std_logic_vector(WIDTH-1 downto 0);    -- deklaracja portu wyjsciowego danych 'sQ' dla projetu 'DE_REG_SYNC'
    aR           :in  std_logic := '0';                      -- deklaracja kasujacego portu wejsciowego 'aR' dla projetu 'DE_REG_ASYNC'
    aS           :in  std_logic := '0';                      -- deklaracja ustawiajacego portu wejsciowego 'aS' dla projetu 'DE_REG_ASYNC'
    aL           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zapisu asynchr. 'aL' dla projetu 'DE_REG_ASYNC'
    aV           :in  std_logic_vector(WIDTH-1 downto 0);    -- deklaracja portu wejsc. asynch. wektora danych 'aV' dla projetu 'DE_REG_ASYNC'
    aC           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zegara 'aC' dla projetu 'DE_REG_ASYNC'
    aE           :in  std_logic := '1';                      -- deklaracja portu wejsciowego zapisu synch. 'aE' dla projetu 'DE_REG_ASYNC'
    aD           :in  std_logic_vector(WIDTH-1 downto 0);    -- deklaracja portu wejsc. synch. wektora danych 'aD' dla projetu 'DE_REG_ASYNC'
    aQ           :out std_logic_vector(WIDTH-1 downto 0)     -- deklaracja portu wyjsciowego danych 'aQ' dla projetu 'DE_REG_ASYNC'
  );
end DE_REG_IMPL;                                             -- zakonczenie deklaracji sprzegu
  
architecture cialo of DE_REG_IMPL is                         -- deklaracja architektury 'cialo' dla sprzegu 'DE_REG_IMPL'
begin						             -- poczatek czesci wykonawczej architektury
   syn: entity work.DE_REG_SYNC  generic map (WIDTH) port map (sR, sS, sL, sV, sC, sE, sD, sQ); -- implementacja projektu 'DE_REG_SYNC'
  asyn: entity work.DE_REG_ASYNC generic map (WIDTH) port map (aR, aS, aL, aV, aC, aE, aD, aQ); -- implementacja projektu 'DE_REG_ASYNC'
end architecture cialo;                                      -- zakonczenie architektury 'cialo'

---------------------------------------------------------------------------------

library ieee;                                                -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                             -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE_REG_IMPL4 is                                       -- deklaracja sprzegu 'DE_REG_IMPL4'
  port(                                                      -- deklaracja portow
    sR           :in  std_logic := '0';                      -- deklaracja kasujacego portu wejsciowego 'sR' dla projetu 'DE_REG_SYNC'
    sS           :in  std_logic := '0';                      -- deklaracja ustawiajacego portu wejsciowego 'sS' dla projetu 'DE_REG_SYNC'
    sL           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zapisu asynchr. 'sL' dla projetu 'DE_REG_SYNC'
    sV           :in  std_logic_vector(3 downto 0);          -- deklaracja portu wejsc. asynch. wektora danych 'sV' dla projetu 'DE_REG_SYNC'
    sC           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zegara 'sC' dla projetu 'DE_REG_SYNC'
    sE           :in  std_logic := '1';                      -- deklaracja portu wejsciowego zapisu synch. 'sE' dla projetu 'DE_REG_SYNC'
    sD           :in  std_logic_vector(3 downto 0);          -- deklaracja portu wejsc. synch. wektora danych 'sD' dla projetu 'DE_REG_SYNC'
    sQ           :out std_logic_vector(3 downto 0);          -- deklaracja portu wyjsciowego danych 'sQ' dla projetu 'DE_REG_SYNC'
    aR           :in  std_logic := '0';                      -- deklaracja kasujacego portu wejsciowego 'aR' dla projetu 'DE_REG_ASYNC'
    aS           :in  std_logic := '0';                      -- deklaracja ustawiajacego portu wejsciowego 'aS' dla projetu 'DE_REG_ASYNC'
    aL           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zapisu asynchr. 'aL' dla projetu 'DE_REG_ASYNC'
    aV           :in  std_logic_vector(3 downto 0);          -- deklaracja portu wejsc. asynch. wektora danych 'aV' dla projetu 'DE_REG_ASYNC'
    aC           :in  std_logic := '0';                      -- deklaracja portu wejsciowego zegara 'aC' dla projetu 'DE_REG_ASYNC'
    aE           :in  std_logic := '1';                      -- deklaracja portu wejsciowego zapisu synch. 'aE' dla projetu 'DE_REG_ASYNC'
    aD           :in  std_logic_vector(3 downto 0);          -- deklaracja portu wejsc. synch. wektora danych 'aD' dla projetu 'DE_REG_ASYNC'
    aQ           :out std_logic_vector(3 downto 0)           -- deklaracja portu wyjsciowego danych 'aQ' dla projetu 'DE_REG_ASYNC'
  );
end DE_REG_IMPL4;                                            -- zakonczenie deklaracji sprzegu
  
architecture cialo of DE_REG_IMPL4 is                        -- deklaracja architektury 'cialo' dla sprzegu 'DE_REG_IMPL4'
begin						             -- poczatek czesci wykonawczej architektury
  impl: entity work.DE_REG_IMPL generic map (4) port map (sR,sS,sL,sV,sC,sE,sD,sQ,aR,aS,aL,aV,aC,aE,aD,aQ); -- impleme. projektu 'DE_REG_IMPL'
end architecture cialo;                                      -- zakonczenie architektury 'cialo'

