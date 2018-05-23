from SU_functions import load_settings_params, load_data, read_logs_and_comparisons, analyses
from scipy import io
import os, glob
import mne
import matplotlib.pyplot as plt
import numpy as np

# Patient 479
probe_names = ['C3', 'C4', 'EMG', 'EOG', 'Ez', 'LAH', 'LSTG', 'Pz', 'RASTG', 'RIFAC', 'RPC', 'PRSTG', 'RPMTG', 'RPSTG', 'RTO']
probe_names = ['EMG', 'EOG', 'Ez', 'LAH', 'LSTG', 'Pz', 'RASTG', 'RIFAC', 'RPC', 'PRSTG', 'RPMTG', 'RPSTG', 'RTO']


print('Loading settings...')
settings = load_settings_params.Settings()

print('Loading parameters...')
params = load_settings_params.Params()

file_name = 'analyses_per_probe.html'

with open(os.path.join(settings.path2figures, settings.patient, file_name), 'w') as f:
    # Beginning of file
    f.write('<head>\n')
    f.write('<title> Analyses per probe </title>\n')
    f.write('</head>\n')
    f.write('<body>\n')

    #
    for probe_name in probe_names:
        HTML_probe_filename = probe_name + '.html'
        f.write('<a href="%s" title="%s"> %s</a><br><br>' % (HTML_probe_filename, probe_name, probe_name))
        with open(os.path.join(settings.path2figures, settings.patient, probe_name + '.html'), 'w') as f_probe:
            # Beginning of probe file
            f_probe.write('<head>\n')
            f_probe.write('<title> %s </title>\n' % probe_name)
            f_probe.write('</head>\n')
            f_probe.write('<body>\n')


            # Find channel numbers in current probe folder
            file_types = 'High-Gamma_' + settings.patient + '_*Blocks_*' + '1, 3, 5' + '*_Event_id_FIRST_WORD*' + probe_name + '*.ncs.png'
            images_without_sorting = glob.glob(os.path.join(settings.path2figures, settings.patient, 'HighGamma', probe_name, file_types))
            channels_in_curr_folder = []; micro_macro = []
            for img in images_without_sorting:
                ch_name = img[img.find('High-Gamma_' + settings.patient) + len('High-Gamma_' + settings.patient) + 9::]
                channels_in_curr_folder.append(int(ch_name[0:ch_name.find('_')]))
                if ('GA' in ch_name) or ('GB' in ch_name):
                    micro_macro.append('micro')
                else:
                    micro_macro.append('macro')
            channels_in_curr_folder = [(ch, mic_mac) for (ch, mic_mac) in sorted(zip(channels_in_curr_folder, micro_macro))]


            # embed images
            for channel, micro_or_macro in channels_in_curr_folder:
                f_probe.write('<font_size="22"> Channel %s (%s) </font>\n' % (str(channel), micro_or_macro) )
                f_probe.write('<br>\n')
                event_ids = ['FINAL']
                for event_id in event_ids:
                    for blocks in ['1, 3, 5', '2, 4, 6']:
                        if blocks == '1, 3, 5' and event_id == 'FINAL': curr_event_id = 'LAST_WORD'
                        if blocks == '2, 4, 6' and event_id == 'FINAL': curr_event_id = 'END_WAV'

                        root_name = 'High-Gamma_' + settings.patient + '_channel_' + str(channel) + '*_Blocks_*' + blocks + '*_Event_id_' + curr_event_id + '*' + probe_name + '*.ncs_lengthSorted.png'
                        curr_img_name = glob.glob(os.path.join(settings.path2figures, settings.patient, 'HighGamma', probe_name, root_name))
                        if len(curr_img_name)> 1:
                            import sys
                            sys.error('More than a single file name was found for current image.')
                        elif len(curr_img_name) < 1:
                            print('Image %s wasn''t found' % root_name)
                        else:
                            f_probe.write('<img class="right" src="%s" style="width:1024px;height:512px;">\n' % os.path.join('HighGamma', probe_name, os.path.basename(curr_img_name[0])))
                        curr_event_id = None

                # f_probe.write('<img class="right" style="width:1024px;height:512px;">\n')
                # Add Reproducability
                root_name_Reproducability = 'reproducability_High-Gamma_' + settings.patient + '_channel_' + str(channel) + '*_Blocks_*' + blocks + '*_Event_id_FIRST_WORD_*.png'
                curr_img_name = glob.glob(os.path.join(settings.path2figures, settings.patient, 'Reproducability', root_name_Reproducability))
                f_probe.write('<img class="right" src="%s" style="width:1024px;height:512px;">\n' % os.path.join('Reproducability', os.path.basename(curr_img_name[0])))

                path2GAT = os.path.join('GAT')
                # f_probe.write()
                f_probe.write('<br>\n')
            # fprintf(fileID, '<font_size="14">%s </font>\n',
            #         ['Location ' cluster.name ' cluster #' num2str(cluster.number) '  mean ' cluster.firing_rate]);
            # fprintf(fileID, '<br>\n');
            # fprintf(fileID, '<img class="right" src="%s" style="width:1024px;height:512px;">\n', curr_fig_name);
            # fprintf(fileID, '<br>\n');

