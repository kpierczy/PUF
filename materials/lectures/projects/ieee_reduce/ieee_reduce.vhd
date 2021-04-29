library ieee;					-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;		-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;		-- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity IEEE_REDUCE is				-- deklaracja sprzegu 'IEEE_REDUCE'
  port ( A : in  std_logic_vector(7 downto 0);	-- deklaracja portu wejsciowego 'A'
	 Y : out std_logic			-- deklaracja portu wyjsciowego 'Y'
       ); 					-- zakonczenie deklaracji listy portow
end IEEE_REDUCE; 				-- zakonczenie deklaracji sprzegu

architecture cialo of IEEE_REDUCE is		-- deklaracja ciala 'cialo' architektury

begin						-- poczatek czesci wykonawczej architektury

  Y <= XOR_REDUCE(A);				-- przypisanie do 'O' operacja XOR_REDUCE na 'A'

end architecture cialo;				-- zakonczenie deklaracji ciala 'cialo'
