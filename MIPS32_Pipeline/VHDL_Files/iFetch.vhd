library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity iFetch is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           branch_address : in STD_LOGIC_VECTOR(31 downto 0);
           pc_src : in STD_LOGIC;         
           jump_address : in STD_LOGIC_VECTOR(31 downto 0);
           jump : in STD_LOGIC;
           pc : out STD_LOGIC_VECTOR(31 downto 0);
           instruction : out STD_LOGIC_VECTOR(31 downto 0));
end iFetch;

-- Problema aleasa:
-- Sa se determine daca un sir de N elemente este progresie aritmetica (diferenta dintre oricare 2 elemente consecutive este constanta).
-- Sirul este stocat in memorie incepand cu adresa A (A?12).
-- A si N se citesc de la adresele 4, respectiv 8.
-- Rezultatul (1=true / 0=false) se va scrie in memorie la adresa 0.

architecture Behavioral of IFetch is
type memROM is array(0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
signal mem : memROM := ( B"010000_00000_00010_0000000000000100",     -- X"40020004" 00: lw $2, 4($0)    PC:0004   Salvam valoarea lui A în $2
                         B"010000_00000_00011_0000000000001000",     -- X"40030008" 01: lw $3, 8($0)    PC:0008   Salvam valoarea lui N în $3
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 02: NoOP            PC:000C
                         B"000000_00000_00010_00101_00000_100000",   -- X"00022820" 03: add $5, $0, $2  PC:0010   Salvam locatia de unde incepe sirul de numere in $5(indexul sirului)
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 04: NoOP            PC:0014
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 05: NoOP            PC:0018
                         B"010000_00101_00110_0000000000000000",     -- X"40A60000" 06: lw $6, 0($5)    PC:001C   $6(nr1) = A(1)
                         B"010000_00101_00111_0000000000000100",     -- X"40A70004" 07: lw $7, 4($5)    PC:0020   $7(nr2) = A(2)
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 08: NoOP            PC:0024
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 09: NoOP            PC:0028
                         B"000000_00111_00110_00100_00000_010000",   -- X"00E62010" 10: sub $4, $7, $6  PC:002C   $4(ratia progresiei) = nr1 - nr2
                         B"100000_00101_00101_0000000000000100",     -- X"80A50004" 11: addi $5, $5, 4  PC:0030   Indexul sirului(index) merge la adresa urmatoare
                         B"100000_00000_00001_0000000000000010",     -- X"80010002" 12: addi $1, $0, 2  PC:0034   Initializam contorul buclei(i) cu 2
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 13: NoOP            PC:0038
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 14: NoOP            PC:003C
                         B"000100_00001_00011_0000000000010110",     -- X"10230016" 15: beq $1, $3, 22  PC:0040   Verificam daca i != N
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 16: NoOP            PC:0044
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 17: NoOP            PC:0048
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 18: NoOP            PC:004C
                         B"010000_00101_00110_0000000000000000",     -- X"40A60000" 19: lw $6, 0($5)    PC:0050   $6(nr1) = A(index)
                         B"010000_00101_00111_0000000000000100",     -- X"40A70004" 20: lw $7, 4($5)    PC:0054   $7(nr2) = A(index+1)
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 21: NoOP            PC:0058
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 22: NoOP            PC:005C
                         B"000000_00111_00110_01000_00000_010000",   -- X"00E64010" 23: sub $8, $7, $6  PC:0060   $8(ratia din bucla) = nr1 - nr2
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 24: NoOP            PC:0064
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 25: NoOP            PC:0068
                         B"000010_01000_00100_0000000000001000",     -- X"09040008" 26: bne $8, $4, 8   PC:006C   Daca ratia din bucla e diferita de ratia progresiei, iesim din bucla
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 27: NoOP            PC:0070
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 28: NoOP            PC:0074
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 29: NoOP            PC:0078
                         B"100000_00000_01010_0000000000000001",     -- X"800A0001" 30: addi $10, $0, 1 PC:007C   Valoarea rezultatului(registrul $10) o setam la 1(true)
                         B"100000_00101_00101_0000000000000100",     -- X"80A50004" 31: addi $5, $5, 4  PC:0080   Indexul sirului(index) merge la adresa urmatoare
                         B"100000_00001_00001_0000000000000001",     -- X"80210001" 32: addi $1, $1, 1  PC:0084   Se incrementeaza contorul i cu 1
                         B"101010_00000000000000000000001111",       -- X"A800000F" 33: j 15            PC:0088   Se sare la instructiunea 8 (reluarea buclei)
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 34: NoOP            PC:008C
                         B"100000_00000_01010_0000000000000000",     -- X"800A0000" 35: addi $10, $0, 0 PC:0090   Se seteaza registrul $10 cu valoarea 0(false) daca s-a iesit din bucla prin BNE
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 36: NoOP            PC:0094
                         B"000000_00000_00000_00000_00000_100000",   -- X"00000020" 37: NoOP            PC:0098
                         B"001000_00000_01010_0000000000000000",     -- X"200A0000" 38: sw $10, 0($0)   PC:009C   Se scrie valoarea din registrul $10 la adresa 0
                         others => X"00000000");


signal d : STD_LOGIC_VECTOR(31 downto 0);
signal q : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
signal sum : STD_LOGIC_VECTOR(31 downto 0);
signal outMUX : STD_LOGIC_VECTOR(31 downto 0);

begin

    process(clk, rst)
    begin
        if rst = '1' then q <= (others => '0');
        elsif rising_edge(clk) then 
            if en = '1' then q <= d;
            end if;
        end if;     
    end process;
 
    pc <= q + X"00000004";  

    with pc_src SELECT 
        outMUX <= q + 4 when '0',
        branch_address when '1',
        (others => 'X') when others; 
    
    with jump SELECT
        d <= outMUX when '0',
        jump_address when '1',
        (others => 'X') when others; 

    instruction <= mem(conv_integer(q(7 downto 2)));
               
end Behavioral;
