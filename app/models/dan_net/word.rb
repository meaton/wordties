#coding: utf-8
module DanNet
  class Word < ActiveRecord::Base
    has_many :syn_sets, :through => :word_senses
    has_many :word_senses
    belongs_to :pos_tag

    def self.suggest_lemmas_by_part(part, filter=false, limit=10)
      case part.length
      when 0
        []
      when 1..2
        Word.prefix_suggestions(part, filter, limit)
      else
        Word.infix_suggestions(part, filter, limit)
      end
    end

    def onthological_clusters
      syn_sets.group_by {|syn_set| syn_set.features.signature }
    end

    private
    def self.infix_suggestions(part, filter, limit)
	if filter == Rails.configuration.search_filter_corepwn + Rails.configuration.search_filter_aligned_postfix    
	  sql = %{  SELECT *
                FROM
                  ( SELECT DISTINCT(w2.lemma)
                    FROM words w1
                      JOIN word_parts wp ON w1.id = wp.word_id
                      JOIN words w2 ON wp.part_of_word_id = w2.id
                    WHERE w1.lemma LIKE ? AND w1.wn_corepwn = TRUE AND w2.wn_corepwn = TRUE
                  ) word
                ORDER BY 
                  POSITION(? in word.lemma) ASC,
                  LENGTH(word.lemma) - LENGTH(?) ASC,
                  word.lemma
                LIMIT ?
	  }
        elsif filter == Rails.configuration.search_filter_ml + Rails.configuration.search_filter_aligned_postfix
          sql = %{  SELECT *
                FROM
                  ( SELECT DISTINCT(w2.lemma)
                    FROM words w1
                      JOIN word_parts wp ON w1.id = wp.word_id
                      JOIN words w2 ON wp.part_of_word_id = w2.id
                    WHERE w1.lemma LIKE ? AND w1.wn_aligned = TRUE AND w2.wn_aligned = TRUE
                  ) word
                ORDER BY 
                  POSITION(? in word.lemma) ASC,
                  LENGTH(word.lemma) - LENGTH(?) ASC,
                  word.lemma
                LIMIT ?
	  }
	else
	  sql = %{  SELECT *
                FROM
                  ( SELECT DISTINCT(w2.lemma)
                    FROM words w1
                      JOIN word_parts wp ON w1.id = wp.word_id
                      JOIN words w2 ON wp.part_of_word_id = w2.id
                    WHERE w1.lemma LIKE ?
                  ) word
                ORDER BY 
                  POSITION(? in word.lemma) ASC,
                  LENGTH(word.lemma) - LENGTH(?) ASC,
                  word.lemma
                LIMIT ?
	  }
	end
      cleaned = sanitize_sql [sql, "#{part}%", part, part, limit]
      ActiveRecord::Base.connection.select_values(cleaned)
    end

    def self.prefix_suggestions(part, filter, limit)
      if filter
	if filter == Rails.configuration.search_filter_corepwn + Rails.configuration.search_filter_aligned_postfix
	sql = %{  SELECT DISTINCT(lemma)
                FROM words
                WHERE lemma LIKE ? AND wn_corepwn = TRUE
                ORDER BY lemma
                LIMIT ?}
	elsif filter == Rails.configuration.search_filter_ml + Rails.configuration.search_filter_aligned_postfix
	sql = %{  SELECT DISTINCT(lemma)
                FROM words
                WHERE lemma LIKE ? AND wn_aligned = TRUE
                ORDER BY lemma
                LIMIT ?}
	end
      else
	 sql = %{  SELECT DISTINCT(lemma)
                FROM words
                WHERE lemma LIKE ?
                ORDER BY lemma
                LIMIT ?}
      end
      cleaned = sanitize_sql [sql, "#{part}%", limit]
      ActiveRecord::Base.connection.select_values(cleaned)
    end

  end
end
