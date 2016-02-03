$argHR = {dsn => "DBI:mysql:###GDB###:localhost",
          GAEVAL_ANN_TBL => 'gseg_cpgat_gene_annotation',
          GAEVAL_ANNselect => 'select uid,gene_structure,gseg_gi,l_pos,r_pos FROM gseg_cpgat_gene_annotation ORDER BY gseg_gi,l_pos,r_pos',
          GAEVAL_SUPPORT_TBL=> 'gseg_cpgat_gbk_gaeval',
          GAEVAL_PROPERTIES_TBL=> 'gseg_cpgat_gbk_gaeval_properties',
          GAEVAL_FLAGS_TBL=> 'gseg_cpgat_gbk_gaeval_flags',
          GAEVAL_ANN_TABLES=>[{ANN_TBL   => 'user_gene_annotation',
                               ANN_conditional => "&&(dbName = '###GDB###')&&(status = 'ACCEPTED')",
                               gsegID_conditional => "gseg_gi = ",
                               ANNselect => 'select uid,geneId,gene_structure,l_pos,r_pos,strand from user_gene_annotation',
                               dsn       => 'DBI:mysql:###GDB###:localhost',
                               dbPASS    => '',
                               dbUSER    => 'yrgateUser'
                              }
                             ],
          GAEVAL_ISO_TABLES=>[{ISO_TBL   => 'gseg_cpgat_cdna_gaeval',
                               PGS_TBL   => 'gseg_cdna_good_pgs',
                               SEQ_TBL   => 'cdna',
                               PGSselect => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_cdna_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
                               TPS_conditional => ""
                              },
                               {ISO_TBL   => 'gseg_cpgat_put_gaeval',
                               PGS_TBL   => 'gseg_put_good_pgs',
                               SEQ_TBL   => 'put',
                               PGSselect => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_put_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
                               TPS_conditional => ""
                              },
                              {ISO_TBL   => 'gseg_cpgat_est_gaeval',
                               PGS_TBL   => 'gseg_est_good_pgs',
                               SEQ_TBL   => 'est',
                               PGSselect => 'select uid,pgs,gseg_gi,l_pos,r_pos,isCognate FROM gseg_est_good_pgs ORDER BY gseg_gi,l_pos,r_pos',
                               _HAS_CLONEPAIRS => 1
                              }],
         };
