library ieee;				-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;	-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity IEEE_AND is			-- deklaracja sprzegu IEEE_AND'
 port (					-- deklaracja listy portow
    I1	:in  std_logic;			-- deklaracja portu wejsciowego 'I1'
    I2	:in  std_logic;			-- deklaracja portu wejsciowego 'I1'
    O	:out std_logic			-- deklaracja portu wyjsciowego 'I1'
);
end IEEE_AND;

architecture cialo of IEEE_AND is	-- deklaracja ciala 'cialo' architektury
begin					-- poczatek czesci wykonawczej

 O <= I1 and I2;			-- przypisanie do 'O' operacja AND na 'I1' i 'I2'

end cialo;				-- zakonczenie deklaracji ciala 'cialo'
