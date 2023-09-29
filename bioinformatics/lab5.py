from Bio import SeqIO

file = open("data/orchid.fasta")

for record in SeqIO.parse(file, "fasta"):
    print(record.id)

seq_iter = SeqIO.parse(open('data/orchid.fasta'), 'fasta')
all_seq = [seq_record for seq_record in seq_iter]
print("\nTotal number of sequences is %s\n" % len(all_seq))

seq_iter = SeqIO.parse(open('data/orchid.fasta'), 'fasta')
max_seq = max(len(seq_record.seq) for seq_record in seq_iter)
print("Length of max sequence is %s\n" % max_seq)

seq_iter = SeqIO.parse(open('data/orchid.fasta'), 'fasta')
seq_under_600 = [seq_record for seq_record in seq_iter if len(seq_record.seq) < 600]
for seq in seq_under_600:
    print(seq.id)

file = open("data/converted.fasta", "w")
for seq_record in seq_under_600:
    SeqIO.write(seq_record, file, "fasta")
    file.write('\n')
