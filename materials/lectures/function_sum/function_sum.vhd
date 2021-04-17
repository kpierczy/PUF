entity FUNCTION_SUM is					-- deklaracja sprzegu FUNCTION_SUM'
  port (  A1 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A1'
          A2 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A2'
	  Y  : out bit_vector(3 downto 0));	 	-- deklaracja portu wyjsciowego 'Y'
end FUNCTION_SUM;	 				-- zakonczenie deklaracji naglowka

architecture cialo of FUNCTION_SUM is		-- deklaracja ciala 'cialo' architektury

  function sumator(A, B :bit_vector) return bit_vector is -- utworzenie funcji 'sumator'
    variable P, S : bit;				-- utworzenie zmiennych 'C' i 'S' w procedurze
    variable Y : bit_vector(A'range);			-- utworzenie zmiennych 'C' i 'S' w procedurze
    procedure sum(A, B :bit; S :out bit ; P :inout bit) is -- utworzenie procedury 'sum'
    begin						-- czesc wykonawcza procedury
      if (P='0') then					-- badanie czy bit przeniesienia jest rowny '0'
        S := A xor B;					-- sumowanie bitowe funkcja 'xor'
        P := A and B;					-- wyznaczenie bitu przeniesienia funkcja 'and'
      else						-- wariant dla 'P' rownego '1'
        S := A xnor B;					-- sumowanie bitowe funkcja 'xnor'
        P := A or   B;					-- wyznaczenie bitu przeniesienia funkcja 'or'
      end if;						-- zakonczenie instukcji warunkowej
    end procedure sum;					-- zakonczenie procedury
  begin							-- czesc wykonawcza procedury
    P := '0';						-- ustawienie wartosci poczatkowej 'P' na '0'
    for i in 0 to Y'length-1 loop			-- petla po kolejnych bitach dla identyfikatora 'i'
      sum(A(i),B(i),S,P);				-- wywolanie procedury wewnetrznej 'sum'
      Y(i) := S;					-- przypisanie zmiennej 'S' do portu 'Y(i)'
    end loop;						-- zakonczenie petli
    if (P='1') then					-- badanie wystapienia przeniesienia 'P'
      Y := (others => '1');				-- ustawienie wartosci maksymalnej
    end if;						-- zakonczenie instukcji warunkowej
    return Y;						-- zwrocenie zmiennej 'Y'
  end function sumator;					-- zakonczenie funcji

begin							-- poczatek czesci wykonawczej

  Y <= sumator(A1, A2);					-- wywolanie funcji 'sumator'

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
