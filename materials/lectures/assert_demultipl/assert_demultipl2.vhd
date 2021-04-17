library ieee;
use     ieee.std_logic_1164.all;

entity ASSERT_DEMULTIPL2 is					-- deklaracja sprzegu ASSERT_DEMULTIPL'
  generic (
    X_SZEROKOSC		:natural := 4;				-- szerokosci slowa 'X'
    Y_SZEROKOSC		:natural := 12				-- szerokosci slowa 'Y'
  );
  port (  X : in  std_logic_vector (X_SZEROKOSC-1 downto 0);	-- deklaracja portu wejsciowego 'X'
          I : in  natural;					-- deklaracja portu wejsciowego 'I'
          Y : out std_logic_vector (Y_SZEROKOSC-1 downto 0)	-- deklaracja portu wyjsciowego 'Y'
       ); 							-- zakonczenie deklaracji listy portow
end ASSERT_DEMULTIPL2;	 					-- zakonczenie deklaracji naglowka

architecture cialo of ASSERT_DEMULTIPL2 is			-- deklaracja ciala 'cialo' architektury

begin								-- poczatek czesci wykonawczej

  process (X, I) is						-- proces asynchroniczny
  begin								-- pocz¹tek ciala procesu 

    Y <= (others =>'0');					-- wyzerowanie wektora wyjsciowek
    for k in 0 to Y'length/X'length-1 loop
      if (k=I) then
        Y((k+1)*X'length-1 downto X'length*k) <= X;		-- wprowadzenie 'X' do 'Y' gd indeksu 'I'
        exit;
      end if;
      assert k<Y'length/X'length-1				-- badanie wykonywania petli
        report "indeks I=" & integer'image(I) & " jest za duzy"	-- informacja gdy regula nie jest spelniona
          severity warning;						-- obsluga niezgodnosci na poziomie ostrzezenia
    end loop;
--   Y((I+1)*X'length-1 downto X'length*I) <= X;		-- wprowadzenie 'X' do 'Y' gd indeksu 'I'

  end process;							-- zakonczenie ciala procesu

end architecture cialo;						-- zakonczenie deklaracji ciala 'cialo'
