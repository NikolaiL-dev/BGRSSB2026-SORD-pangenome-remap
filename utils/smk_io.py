def read_samples_tab(path2tab:str) -> dict:
    '''
    Parse the table with infotamtion about samples
    '''
    samples = dict()
    with open(path2tab, "r") as f:
        for line in f:
            if not line: continue
            elif line.startswith("#"):
                keys = line.strip().split()
            else:
                sample_data = line.strip().split()
                samples[sample_data[0]] = {k:v for k, v in  zip(keys[1:], sample_data[1:])}

    return samples


def define_input(sample:str, samples:dict) -> tuple:
    '''
    Check data in the samples.tsv. 
    if FILEFORMAT is BAM, then it returns path to BAM
    overwise it returns path to R1/R2 fq

    samples - dict - samples.tsv as dictionary
    sample  - str  - target sample
    '''

    if samples[sample]['FILEFORMAT'] == 'BAM': return tuple([samples[sample]['BAM']])
    elif  samples[sample]['FILEFORMAT'] == 'FQ': return tuple([samples[sample]['R1'], samples[sample]['R2']])
    else: assert samples[sample]['FILEFORMAT'] in ['BAM', 'FQ'], '[ERROR] incorrect format of samples.tsv file'